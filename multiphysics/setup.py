"""
Setup script for Quantum Gravity Materials Framework

Complete integration of:
- Numerical Relativity (AMSS-NCKU)
- Quantum Field Theory (QuTiP, QEDTOOL)
- Materials Science (Pymatgen, ASE, PySCF)
- Condensed Matter (PythTB, Kwant, quantum-tensors)
- Electromagnetics (MEEP)
"""

from setuptools import setup, find_packages
import os

# Read README
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

# Read requirements
with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="quantum-gravity-materials-framework",
    version="1.0.0",
    author="Your Team",
    author_email="your.email@example.com",
    description="Complete framework for quantum field theory, materials science, and numerical relativity",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/your-org/quantum-gravity-materials-framework",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Science/Research",
        "Topic :: Scientific/Engineering :: Physics",
        "Topic :: Scientific/Engineering :: Chemistry",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: C++",
    ],
    python_requires=">=3.8",
    install_requires=[
        "numpy>=1.21.0",
        "scipy>=1.7.0",
        "matplotlib>=3.4.0",
        "h5py>=3.3.0",
        "tqdm>=4.62.0",
    ],
    extras_require={
        "quantum": [
            "qutip>=4.7.0",
        ],
        "em": [
            "meep>=1.25.0",
        ],
        "materials": [
            "pymatgen>=2022.0.0",
            "spglib>=1.16.0",
            "ase>=3.22.0",
            "pyscf>=2.0.0",
        ],
        "condensed_matter": [
            "pythtb>=1.7.2",
            "kwant>=1.4.0",
            "quantum-tensors>=0.3.0",
        ],
        "dev": [
            "pytest>=6.2.0",
            "pytest-cov>=2.12.0",
            "black>=21.6b0",
            "flake8>=3.9.0",
            "mypy>=0.910",
            "sphinx>=4.1.0",
            "jupyterlab>=3.1.0",
        ],
        "all": [
            "qutip>=4.7.0",
            "meep>=1.25.0",
            "pymatgen>=2022.0.0",
            "spglib>=1.16.0",
            "ase>=3.22.0",
            "pyscf>=2.0.0",
            "pythtb>=1.7.2",
            "kwant>=1.4.0",
            "quantum-tensors>=0.3.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "qgmf-run=integration.complete_framework:main",
            "qgmf-test=tests.run_all:main",
            "qgmf-setup=scripts.setup_environment:main",
        ],
    },
    package_data={
        "": ["*.yaml", "*.json", "*.cif", "*.xyz"],
    },
    include_package_data=True,
    zip_safe=False,
)
