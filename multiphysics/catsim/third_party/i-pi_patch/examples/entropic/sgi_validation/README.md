# SGI Validation Test

Validates entropic Langevin dynamics against Stern-Gerlach interferometry data
from Table 1 (page 8) of the paper.

## Expected Results

- **Dissipation rate**: λ = 5.3 × 10³ s⁻¹
- **Atomic temperature**: T_atom = 3 × 10⁻⁷ K
- **Planckian ratio**: Π = 0.13 ± 0.02
- **Evolution time**: T = 100 ms
- **Visibility decay**: V(T) = exp(-λT) ≈ 0.59

## Running
```bash
# Start i-PI server
i-pi input.xml &

# Start driver (harmonic trap for atom)
python ../../../drivers/py/sgi_driver.py
```

## Validation

Check `entropic.out` file:
```python
import numpy as np

data = np.loadtxt('sgi_validation.entropic.out')
time = data[:, 1]  # ps
visibility = data[:, 3]

# Expected visibility decay
lambda_SGI = 5.3e3  # s^-1
V_predicted = np.exp(-lambda_SGI * time * 1e-12)

# Plot comparison
import matplotlib.pyplot as plt
plt.plot(time, visibility, label='Simulated')
plt.plot(time, V_predicted, '--', label='Theory')
plt.xlabel('Time (ps)')
plt.ylabel('Visibility')
plt.legend()
plt.savefig('visibility_validation.png')
```

Expected: simulated and theoretical curves should match within < 2%.
