#!/usr/bin/env python3
"""Build the Story010 low-HP damage mix from the stable normal damage cue."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
OUTPUT_DURATION_SEC = 0.38
TARGET_PEAK_DBFS = -4.3


def read_pcm16_mono(path: Path) -> list[float]:
    with wave.open(str(path), "rb") as source:
        if (
            source.getnchannels() != 1
            or source.getsampwidth() != 2
            or source.getframerate() != SAMPLE_RATE
        ):
            raise ValueError("Expected 44.1 kHz mono 16-bit PCM source")
        frame_count = source.getnframes()
        samples = struct.unpack(f"<{frame_count}h", source.readframes(frame_count))
    return [sample / 32768.0 for sample in samples]


def low_pass(samples: list[float], cutoff_hz: float) -> list[float]:
    alpha = 1.0 - math.exp(-2.0 * math.pi * cutoff_hz / SAMPLE_RATE)
    output: list[float] = []
    state = 0.0
    for sample in samples:
        state += alpha * (sample - state)
        output.append(state)
    return output


def high_pass(samples: list[float], cutoff_hz: float) -> list[float]:
    low = low_pass(samples, cutoff_hz)
    return [sample - low_sample for sample, low_sample in zip(samples, low)]


def add_delayed(
    output: list[float],
    source: list[float],
    delay_sec: float,
    gain: float,
    damping_sec: float,
) -> None:
    delay_frames = round(delay_sec * SAMPLE_RATE)
    for source_index, sample in enumerate(source):
        output_index = source_index + delay_frames
        if output_index >= len(output):
            break
        elapsed = source_index / SAMPLE_RATE
        damping = math.exp(-elapsed / damping_sec)
        output[output_index] += sample * gain * damping


def build_mix(dry_source: list[float]) -> list[float]:
    frame_count = round(OUTPUT_DURATION_SEC * SAMPLE_RATE)
    output = [0.0] * frame_count

    dark_body = high_pass(low_pass(dry_source, 2_100.0), 35.0)
    low_body = high_pass(low_pass(dry_source, 180.0), 42.0)
    reverb_source = high_pass(low_pass(dry_source, 1_450.0), 38.0)

    for index, sample in enumerate(dark_body):
        if index >= frame_count:
            break
        output[index] += sample * 0.58
        output[index] += low_body[index] * 0.42

    # Short, mono early reflections keep the cue readable without sounding spacious.
    add_delayed(output, reverb_source, 0.072, 0.40, 0.19)
    add_delayed(output, reverb_source, 0.111, 0.30, 0.17)
    add_delayed(output, reverb_source, 0.158, 0.22, 0.15)

    # A decaying 86/129 Hz resonance carries the weight on small speakers.
    for index in range(frame_count):
        time_sec = index / SAMPLE_RATE
        if time_sec < 0.018:
            continue
        resonance_time = time_sec - 0.018
        envelope = math.exp(-resonance_time / 0.135)
        output[index] += math.sin(2.0 * math.pi * 86.0 * resonance_time) * 0.095 * envelope
        output[index] += math.sin(2.0 * math.pi * 129.0 * resonance_time) * 0.040 * envelope

    # Force a controlled decay so the tail reads as damping, not a sustained tone.
    fade_start = 0.31
    for index in range(frame_count):
        time_sec = index / SAMPLE_RATE
        if time_sec <= fade_start:
            continue
        fade_progress = min(1.0, (time_sec - fade_start) / (OUTPUT_DURATION_SEC - fade_start))
        smooth_fade = 1.0 - fade_progress * fade_progress * (3.0 - 2.0 * fade_progress)
        output[index] *= smooth_fade

    # Gentle saturation reins in the dry transient so the damped tail remains audible.
    output = [math.tanh(sample * 3.0) for sample in output]
    peak = max(abs(sample) for sample in output)
    target_peak = 10.0 ** (TARGET_PEAK_DBFS / 20.0)
    scale = target_peak / peak
    return [max(-1.0, min(1.0, sample * scale)) for sample in output]


def write_pcm16_mono(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    encoded = struct.pack(
        f"<{len(samples)}h",
        *(round(max(-1.0, min(0.999969, sample)) * 32767.0) for sample in samples),
    )
    with wave.open(str(path), "wb") as target:
        target.setnchannels(1)
        target.setsampwidth(2)
        target.setframerate(SAMPLE_RATE)
        target.writeframes(encoded)


def rms_db(samples: list[float]) -> float:
    rms = math.sqrt(sum(sample * sample for sample in samples) / len(samples))
    return 20.0 * math.log10(max(rms, 1e-6))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    output_samples = build_mix(read_pcm16_mono(args.input))
    write_pcm16_mono(args.output, output_samples)
    output_bytes = args.output.read_bytes()
    tail_start = round(0.16 * SAMPLE_RATE)
    final_start = len(output_samples) - round(0.01 * SAMPLE_RATE)
    print(
        json.dumps(
            {
                "output": str(args.output),
                "sha256": hashlib.sha256(output_bytes).hexdigest(),
                "duration_sec": len(output_samples) / SAMPLE_RATE,
                "peak_dbfs": 20.0
                * math.log10(max(abs(sample) for sample in output_samples)),
                "rms_dbfs": rms_db(output_samples),
                "tail_after_160ms_rms_dbfs": rms_db(output_samples[tail_start:]),
                "final_10ms_rms_dbfs": rms_db(output_samples[final_start:]),
            },
            indent=2,
            sort_keys=True,
        )
    )


if __name__ == "__main__":
    main()
