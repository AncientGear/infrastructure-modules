"""Offline structural guards; no provider initialization or cluster access."""
import re
import unittest
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1]


class OperatorContract(unittest.TestCase):
    def setUp(self):
        self.module = (MODULE / "main.tf").read_text()
        self.variables = (MODULE / "variables.tf").read_text()

    def test_resource_budgets(self):
        pattern = (
            r"\bresources\s*=\s*\{\s*"
            r"requests\s*=\s*\{\s*"
            r'cpu\s*=\s*"([^"]+)"\s*'
            r'memory\s*=\s*"([^"]+)"\s*\}\s*'
            r"limits\s*=\s*\{\s*"
            r'memory\s*=\s*"([^"]+)"\s*\}\s*\}'
        )
        operator = self.module.split("webhook", 1)[0]
        webhook = self.module.split("webhook", 1)[1].split(
            "certController", 1
        )[0]
        cert_controller = self.module.split("certController", 1)[1]

        for name, section, expected in [
            ("operator", operator, ("100m", "128Mi", "256Mi")),
            ("webhook", webhook, ("50m", "64Mi", "128Mi")),
            ("certController", cert_controller, ("50m", "64Mi", "128Mi")),
        ]:
            with self.subTest(component=name):
                self.assertEqual(re.findall(pattern, section), [expected])

    def test_pinned_release_owns_crds(self):
        # Published 2.11.0 archive inspected before pinning: both ExternalSecret
        # and SecretStore serve/store v1; default image manifest includes arm64.
        # Archive SHA256: 8199b42fe80b871c6a86233a80bb14f599fd6e1e6462c1216d836577f845e161
        # This guard protects the verified pin, not live API/image availability.
        self.assertRegex(self.module, r'version\s*=\s*"2\.11\.0"')
        self.assertIn('repository       = "https://charts.external-secrets.io"', self.module)
        self.assertIn("installCRDs = true", self.module)
        for component in ["webhook", "certController"]:
            self.assertRegex(
                self.module,
                rf"\b{component}\s*=\s*\{{\s*create\s*=\s*true\b",
            )

    def test_global_arm_shared_scheduling(self):
        # Published chart 2.11.0 uses global fallback for each deployment.
        self.assertRegex(self.module, r'global\s*=\s*\{\s*(?:#[^\n]*\n\s*)*nodeSelector')
        for pattern in [
            r'"kubernetes.io/arch"\s*=\s*"arm64"',
            r'workload\s*=\s*"shared"',
            r'key\s*=\s*"workload"',
            r'operator\s*=\s*"Equal"',
            r'value\s*=\s*"shared"',
            r'effect\s*=\s*"NoSchedule"',
        ]:
            self.assertRegex(self.module, pattern)

    def test_required_input_declarations(self):
        for name in ["cluster_name", "region"]:
            with self.subTest(variable=name):
                self.assertIn(f'variable "{name}"', self.variables)


if __name__ == "__main__":
    unittest.main()
