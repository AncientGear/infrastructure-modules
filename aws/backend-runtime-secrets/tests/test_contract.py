import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class RuntimeContract(unittest.TestCase):
    def test_exact_irsa_and_secret_scope(self):
        text = (ROOT / 'main.tf').read_text()
        for token in ['StringEquals', ':sub', ':aud', 'sts.amazonaws.com',
                      'system:serviceaccount:backend-dev:backend-runtime-secrets',
                      'secret:dev/dealengine/backend-runtime-??????',
                      'secretsmanager:GetSecretValue', 'secretsmanager:DescribeSecret']:
            self.assertIn(token, text)
        self.assertNotIn('secretsmanager:*', text)
        self.assertNotIn('aws_secretsmanager_secret_version', text)

    def test_namespaced_chart_contract(self):
        text = (ROOT / 'chart/templates/resources.yaml').read_text()
        for token in ['kind: ServiceAccount', 'kind: SecretStore',
                      'kind: ExternalSecret', 'external-secrets.io/v1',
                      'property: DATABASE_URL', 'property: TOKEN_SECRET',
                      'name: backend-runtime', 'kind: SecretStore',
                      'serviceAccountRef:', 'eks.amazonaws.com/role-arn']:
            self.assertIn(token, text)
        for kind in ['Deployment', 'Service', 'HTTPRoute', 'Namespace', 'ClusterSecretStore']:
            self.assertNotIn('kind: ' + kind + '\n', text)

    def test_release_does_not_create_namespace(self):
        text = (ROOT / 'main.tf').read_text()
        self.assertIn('create_namespace = false', text)
        self.assertIn('chart            = "${path.module}/chart"', text)
        self.assertIn('aws_iam_role.runtime.arn', text)
        self.assertIn('aws_iam_role_policy.runtime', text)


if __name__ == '__main__':
    unittest.main()
