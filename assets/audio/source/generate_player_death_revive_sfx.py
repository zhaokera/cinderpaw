#!/usr/bin/env python3
"""Generate deterministic player death and revive PCM cues for Audio Story011."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
DEATH_DURATION_SEC = 1.5
REVIVE_DURATION_SEC = 0.9


def smoothstep(value: float) -> float:
    clamped = max(0.0, min(1.0, value))
    return clamped * clamped * (3.0 - 2.0 * clamped)


def normalize(samples: list[float], target_peak_dbfs: float) -> list[float]:
    peak = max(abs(sample) for sample in samples)
    target_peak = 10.0 ** (target_peak_dbfs / 20.0)
    scale = target_peak / max(peak, 1e-9)
    return [max(-1.0, min(0.999969, sample * scale)) for sample in samples]


def build_death_cue() -> list[float]:
    frame_count = round(DEATH_DURATION_SEC * SAMPLE_RATE)
    output = [0.0] * frame_count
    noise_state = 0xC1D3A7

    for index in range(frame_count):
        time_sec = index / SAMPLE_RATE
        sample = 0.0

        if time_sec < 0.18:
            impact_env = math.exp(-time_sec / 0.055)
            low_body = math.sin(2.0 * math.pi * 58.0 * time_sec) * 0.78
            metal_body = math.sin(2.0 * math.pi * 116.0 * time_sec) * 0.23
            noise_state = (1_103_515_245 * noise_state + 12_345) & 0x7FFFFFFF
            noise = (noise_state / 0x7FFFFFFF) * 2.0 - 1.0
            sample += (low_body + metal_body + noise * 0.16) * impact_env

        if 1.18 <= time_sec < DEATH_DURATION_SEC:
            chord_time = time_sec - 1.18
            attack = smoothstep(chord_time / 0.055)
            release = 1.0 - smoothstep(
                max(0.0, chord_time - 0.20) / (DEATH_DURATION_SEC - 1.38)
            )
            vibrato = math.sin(2.0 * math.pi * 4.2 * chord_time) * 0.003
            chord = (
                math.sin(2.0 * math.pi * 65.41 * (1.0 + vibrato) * chord_time) * 0.42
                + math.sin(2.0 * math.pi * 77.78 * (1.0 + vibrato) * chord_time) * 0.31
                + math.sin(2.0 * math.pi * 98.00 * (1.0 + vibrato) * chord_time) * 0.18
            )
            bow_texture = math.sin(2.0 * math.pi * 196.0 * chord_time) * 0.035
            sample += (chord + bow_texture) * attack * release

        output[index] = math.tanh(sample * 1.35)

    return normalize(output, -3.8)


def build_revive_cue() -> list[float]:
    frame_count = round(REVIVE_DURATION_SEC * SAMPLE_RATE)
    output = [0.0] * frame_count
    phase = 0.0

    for index in range(frame_count):
        time_sec = index / SAMPLE_RATE
        sample = 0.0

        if time_sec < 0.56:
            progress = time_sec / 0.56
            if progress < 0.45:
                pitch = 470.0 + 310.0 * smoothstep(progress / 0.45)
            else:
                pitch = 780.0 - 300.0 * smoothstep((progress - 0.45) / 0.55)
            pitch *= 1.0 + math.sin(2.0 * math.pi * 5.6 * time_sec) * 0.012
            phase += 2.0 * math.pi * pitch / SAMPLE_RATE
            attack = smoothstep(time_sec / 0.045)
            release = 1.0 - smoothstep(max(0.0, time_sec - 0.34) / 0.22)
            mew = (
                math.sin(phase) * 0.50
                + math.sin(phase * 2.0) * 0.18
                + math.sin(phase * 3.0) * 0.07
            )
            sample += mew * attack * release

        if time_sec >= 0.16:
            shimmer_time = time_sec - 0.16
            shimmer_env = smoothstep(shimmer_time / 0.035) * math.exp(-shimmer_time / 0.34)
            sample += math.sin(2.0 * math.pi * 659.25 * shimmer_time) * 0.20 * shimmer_env
            sample += math.sin(2.0 * math.pi * 987.77 * shimmer_time) * 0.12 * shimmer_env
            sample += math.sin(2.0 * math.pi * 1318.51 * shimmer_time) * 0.06 * shimmer_env

        if time_sec > 0.77:
            sample *= 1.0 - smoothstep((time_sec - 0.77) / 0.13)
        output[index] = math.tanh(sample * 1.2)

    return normalize(output, -5.0)


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
    rms = math.sqrt(sum(sample * sample for sample in samples) / max(1, len(samples)))
    return 20.0 * math.log10(max(rms, 1e-9))


def metrics(path: Path, samples: list[float]) -> dict[str, object]:
    peak = max(abs(sample) for sample in samples)
    return {
        "path": f"res://{path.as_posix()}",
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "duration_sec": len(samples) / SAMPLE_RATE,
        "peak_dbfs": round(20.0 * math.log10(max(peak, 1e-9)), 3),
        "rms_dbfs": round(rms_dbfs(samples), 3),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("death_output", type=Path)
    parser.add_argument("revive_output", type=Path)
    parser.add_argument("manifest_output", type=Path)
    args = parser.parse_args()

    death_samples = build_death_cue()
    revive_samples = build_revive_cue()
    write_pcm16_mono(args.death_output, death_samples)
    write_pcm16_mono(args.revive_output, revive_samples)

    manifest = {
        "generated_on": "2026-07-20",
        "story_id": "audio-system-story-011",
        "generator": "deterministic procedural PCM synthesis via Python wave module",
        "generator_script": (
            "res://assets/audio/source/generate_player_death_revive_sfx.py"
        ),
        "generation_command": (
            "python3 assets/audio/source/generate_player_death_revive_sfx.py "
            "assets/audio/sfx/sfx_player_death.wav "
            "assets/audio/sfx/sfx_player_revive.wav "
            "assets/audio/source/player_death_revive_sfx_generation_20260720.json"
        ),
        "format": {
            "codec": "PCM signed 16-bit little-endian WAV",
            "sample_rate_hz": SAMPLE_RATE,
            "channels": 1,
        },
        "assets": {
            "sfx_player_death": {
                **metrics(args.death_output, death_samples),
                "description": (
                    "Heavy landing impact, one-second silence, then a low sad "
                    "minor-string tail within the 1.5-second death hold."
                ),
            },
            "sfx_player_revive": {
                **metrics(args.revive_output, revive_samples),
                "description": (
                    "Gentle synthesized feline mew with rising cat-eye-gold "
                    "harmonics for the revive halo and ambience return."
                ),
            },
        },
        "status": "procedural_baseline_replaceable",
        "image_generation": "not_applicable_audio_only",
    }
    args.manifest_output.parent.mkdir(parents=True, exist_ok=True)
    args.manifest_output.write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
