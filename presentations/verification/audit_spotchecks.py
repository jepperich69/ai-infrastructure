"""Independent arithmetic checks for the anonymous-paper slides."""

from math import pi, sqrt


def close(actual: float, expected: float, tol: float = 5e-3) -> None:
    assert abs(actual - expected) <= tol, (actual, expected)


# Paper A: Table 1 normalized objectives and Table 2 geometric areas.
close(1.16 / 2.22, 0.5233)
close(3.50 / 4.49, 0.7784)
# The reported outer parking annulus uses a 1 km increment.
close(pi * ((5.8552 + 1.0) ** 2 - 5.8552**2), 39.93, 0.02)
close(pi * (5.8552**2 - 2.5**2), 88.06, 0.02)
close(pi * 2.5**2, 19.63, 0.02)

# Paper B: Example 1. The paper uses H=diag(4,1,4,1) after stating
# variance 4; using the corresponding standard deviation gives H=diag(2,1,2,1).
paper_metric = sqrt((10 / 4) ** 2 + (-10) ** 2 + (5 / 4) ** 2 + (-5) ** 2)
variance_consistent_metric = sqrt(
    (10 / 2) ** 2 + (-10) ** 2 + (5 / 2) ** 2 + (-5) ** 2
)
close(paper_metric, sqrt(132.8125), 1e-12)
close(variance_consistent_metric, 12.5, 1e-12)

# Paper C: accounting identities printed in Table 5.
assert 727_732 + 15_673 - 94_943 == 648_462
assert 715_487 - 96_686 == 618_801

print("All anonymous-paper arithmetic spot checks pass.")
print(f"Paper B printed metric: {paper_metric:.4f}")
print(f"Paper B variance-consistent metric: {variance_consistent_metric:.4f}")
