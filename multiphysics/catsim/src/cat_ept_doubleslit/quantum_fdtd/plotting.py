"""Small plotting helpers for quantum_fdtd demos."""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def plot_wavefunction(x: np.ndarray, psi: np.ndarray, title: str = "Wavefunction"):
    plt.figure()
    plt.plot(x, np.real(psi), label="Re")
    plt.plot(x, np.imag(psi), label="Im")
    plt.xlabel("x (m)")
    plt.ylabel("ψ")
    plt.title(title)
    plt.legend()
    plt.tight_layout()


def compare_probabilities(x: np.ndarray, p1: np.ndarray, p2: np.ndarray, title: str = "|ψ|² comparison"):
    plt.figure()
    plt.plot(x, p1, label="baseline")
    plt.plot(x, p2, label="reference")
    plt.xlabel("x (m)")
    plt.ylabel("|ψ|²")
    plt.title(title)
    plt.legend()
    plt.tight_layout()


def compare_observables_time(t: np.ndarray, series1: dict[str, np.ndarray], series2: dict[str, np.ndarray]):
    # expects same keys in both
    for k in series1.keys():
        plt.figure()
        plt.plot(t, series1[k], label=f"baseline {k}")
        plt.plot(t, series2[k], label=f"reference {k}")
        plt.xlabel("t (s)")
        plt.ylabel(k)
        plt.title(k)
        plt.legend()
        plt.tight_layout()
