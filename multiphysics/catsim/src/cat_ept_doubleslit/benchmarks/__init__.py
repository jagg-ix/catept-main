"""Benchmarks and cross-backend validation helpers."""

from .compare_backends import (  # noqa: F401
    CompareResult,
    compare_dense_vs_qutip_nonhermitian_t,
    compare_dense_vs_qutip_nonhermitian_tau,
)
