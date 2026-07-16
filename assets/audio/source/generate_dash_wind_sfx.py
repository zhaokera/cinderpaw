#!/usr/bin/env python3
"""Generate the deterministic Cinderpaw Dash air-whoosh cue."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
DURATION_SEC = 0.20
TARGET_PEAK_DBFS = -5.0
RANDOM_SEED = 31_031


def low_pass(samples: list[float], cutoff_hz: float) -> list[float]:
    alpha = 1.0 - math.exp(-2.0 * math.pi * cutoff_hz / SAMPLE_RATE)
    state = 0.0
    output: list[float] = []
    for sample in samples:
        state += alpha * (sample - state)
        output.append(state)
    return output


def high_pass(samples: list[float], cutoff_hz: float) -> list[float]:
    low = low_pass(samples, cutoff_hz)
    return [sample - low_sample for sample, low_sample in zip(samples, low)]


def build_dash_wind() -> list[float]:
    frame_count = round(DURATION_SEC * SAMPLE_RATE)
    rng = random.Random(RANDOM_SEED)
    noise = [rng.uniform(-1.0, 1.0) for _ in range(frame_count)]
    broad_air = high_pass(low_pass(noise, 7_600.0), 850.0)
    fast_edge = high_pass(low_pass(noise, 11_000.0), 3_200.0)
    output: list[float] = []

    for index in range(frame_count):
        time_sec = index / SAMPLE_RATE
        attack = min(1.0, time_sec / 0.018)
        attack = attack * attack * (3.0 - 2.0 * attack)
        decay = math.exp(-max(0.0, time_sec - 0.018) / 0.067)
        end_fade = min(1.0, max(0.0, (DURATION_SEC - time_sec) / 0.025))
        envelope = attack * decay * end_fade
        sweep = max(0.0, 1.0 - time_sec / DURATION_SEC)
        sample = broad_air[index] * (0.72 + 0.18 * sweep)
        sample += fast_edge[index] * (0.50 * sweep)
        output.append(sample * envelope)

    peak = max(abs(sample) for sample in output)
    target_peak = 10.0 ** (TARGET_PEAK_DBFS / 20.0)
    scale = target_peak / max(peak, 1e-9)
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


def rms_dbfs(samples: list[float]) -> float:
    rms = math.sqrt(sum(sample * sample for sample in samples) / len(samples))
    return 20.0 * math.log10(max(rms, 1e-9))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    samples = build_dash_wind()
    write_pcm16_mono(args.output, samples)
    output_bytes = args.output.read_bytes()
    tail = samples[round(0.16 * SAMPLE_RATE):]
    print(json.dumps({
        "output": str(args.output),
        "sha256": hashlib.sha256(output_bytes).hexdigest(),
        "duration_sec": len(samples) / SAMPLE_RATE,
        "sample_rate_hz": SAMPLE_RATE,
        "channels": 1,
        "sample_width_bits": 16,
        "peak_dbfs": 20.0 * math.log10(max(abs(sample) for sample in samples)),
        "rms_dbfs": rms_dbfs(samples),
        "tail_after_160ms_rms_dbfs": rms_dbfs(tail),
        "random_seed": RANDOM_SEED,
    }, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
