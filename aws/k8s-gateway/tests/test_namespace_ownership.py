import unittest
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1]


class NamespaceOwnershipTest(unittest.TestCase):
    def test_gateway_consumes_namespaces_without_owning_them(self):
        main = (MODULE / "main.tf").read_text()
        outputs = (MODULE / "outputs.tf").read_text()
        self.assertNotIn('resource "kubernetes_namespace_v1"', main)
        self.assertNotIn("kubernetes_namespace_v1.", main + outputs)
        self.assertIn("namespace = var.platform_namespace", main)
        self.assertIn('"gateway.platform.deal-engine.io/authorized" = "true"', main)
        self.assertIn('from = "Selector"', main)
        self.assertIn("value       = var.platform_namespace", outputs)
        self.assertIn("sort(tolist(var.authorized_application_namespaces))", outputs)


if __name__ == "__main__":
    unittest.main()
