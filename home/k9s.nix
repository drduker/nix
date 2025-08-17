{ ... }: {
    programs.k9s = {
        enable = true;
        settings.k9s.ui.skin = "skin";
        settings.k9s.ui.logoless = false;
        settings.k9s.body.logoUrl = "https://gist.githubusercontent.com/drduker/9fcdfac7782e70897cc3e32af5f49c26/raw/db7f6b4786f1cb197356fc42057dd6b65be37649/jet";
        skins.skin.k9s.body.logoUrl = "https://gist.githubusercontent.com/drduker/9fcdfac7782e70897cc3e32af5f49c26/raw/db7f6b4786f1cb197356fc42057dd6b65be37649/jet";
        views = {
        views = {
            "ks" = {
            columns =
                [ "NAMESPACE" "NAME" "SUS:.spec.suspend" "READY" "STATUS" "AGE" ];
            };
            "hr" = {
            columns =
                [ "NAMESPACE" "NAME" "SUS:.spec.suspend" "READY" "STATUS" "AGE" ];
            };
            "v1/nodes" = {
            columns = [
                "AGE"
                "STATUS"
                "NAME:.status.addresses[0].address"
                "VERSION|S"
                "POO:.metadata.labels.karpenter\\.sh/nodepool"
                "ROLE|H"
                "TAINT1:.spec.taints[0].key"
            ];
            };
        };
        };
        plugins = {
        network-test = {
            shortCut = "Shift-4";
            description = "ntwrk-util";
            scopes = [ "pods" ];
            command = "sh";
            background = true;
            args = [
            "-c"
            ''
                kubectl run -it -n $NAMESPACE network-utility \
                --image=registry1.dso.mil/ironbank/opensource/kubernetes-e2e-test/dnsutils:1.3-ubi9 \
                --overrides='{
                    "apiVersion": "v1",
                    "spec": {
                    "containers": [{
                        "name": "network-utility",
                        "image": "registry1.dso.mil/ironbank/opensource/kubernetes-e2e-test/dnsutils:1.3-ubi9",
                        "command": ["/bin/bash"],
                        "args": ["-c", "echo Running network connectivity checks...; run_check() { local cmd=$1; local desc=$2; echo -n \"Checking $desc...\"; eval $cmd >/dev/null 2>&1; local rc=$?; if [ $rc -eq 0 ]; then echo \"✓ (rc=$rc)\"; else echo \"✗ (rc=$rc)\"; fi; }; run_check \"nslookup kubernetes.default.svc.cluster.local\" \"k8s DNS\"; run_check \"nslookup s3.us-gov-east-1.amazonaws.com\" \"S3 Gov East DNS\"; run_check \"nslookup s3.us-east-1.amazonaws.com\" \"S3 East DNS\"; run_check \"curl -v --max-time 10 http://istiod.istio-system.svc.cluster.local:15012/ready\" \"Istio ready\"; run_check \"curl -sk --max-time 30 https://kubernetes.default.svc.cluster.local:443/healthz\" \"K8s API health\"; run_check \"curl -v --max-time 10 https://s3.us-gov-east-1.amazonaws.com\" \"S3 Gov East\"; run_check \"curl -v --max-time 10 https://sts.us-gov-east-1.amazonaws.com/\" \"STS Gov East\"; run_check \"curl -v --max-time 10 https://apple.com\" \"Apple.com connectivity\"; sleep 1800"],
                        "serviceAccount": "default",
                        "securityContext": {
                        "capabilities": {
                            "drop": ["ALL"]
                        }
                        }
                    }],
                    "imagePullSecrets": [{
                        "name": "private-registry"
                    }]
                    }
                }' \
                --rm -- bash &
            ''
            ];
        };

        add-delete-label = {
            shortCut = "Ctrl-L";
            description = "add-delete-label";
            scopes = [ "all" ];
            command = "kubectl";
            background = true;
            args = [
            "label"
            "-n"
            "$NAMESPACE"
            "$RESOURCE_NAME/$NAME"
            "delete=allow"
            ];
        };

        aws-cli = {
            shortCut = "Shift-3";
            description = "aws-cli";
            scopes = [ "pods" ];
            command = "sh";
            background = true;
            args = [
            "-c"
            ''
                kubectl run -it -n $NAMESPACE aws-cli \
                --image=registry1.dso.mil/ironbank/opensource/amazon/aws-cli:2.11.2 \
                --overrides='{
                    "apiVersion": "v1",
                    "spec": {
                    "containers": [{
                        "name": "aws-cli",
                        "image": "registry1.dso.mil/ironbank/opensource/amazon/aws-cli:2.11.2",
                        "command": ["/bin/bash"],
                        "args": ["-c", "sleep 1800"],
                        "serviceAccount": "default",
                        "securityContext": {
                        "runAsUser": 1001,
                        "runAsGroup": 1001,
                        "fsGroup": 1001,
                        "capabilities": {
                            "drop": ["ALL"]
                        }
                        }
                    }],
                    "imagePullSecrets": [{
                        "name": "private-registry"
                    }]
                    }
                }' \
                --command -- bash &
            ''
            ];
        };
        psql-client = {
            shortCut = "Shift-1";
            description = "psql";
            scopes = [ "pods" ];
            command = "sh";
            background = true;
            args = [
            "-c"
            ''
                kubectl run -it -n $NAMESPACE psql-client \
                --image=registry.gamewarden.io/ironbank-proxy/ironbank/bitnami/postgres:16.3.0 \
                --overrides='{
                    "apiVersion": "v1",
                    "spec": {
                    "containers": [{
                        "name": "psql-client",
                        "image": "registry.gamewarden.io/ironbank-proxy/ironbank/bitnami/postgres:16.3.0",
                        "command": ["/bin/bash"],
                        "args": ["-c", "sleep 1800"],
                        "serviceAccount": "default",
                        "env": [
                        {
                            "name": "POSTGRES_USER",
                            "value": "DBAdmin"
                        },
                        {
                            "name": "DATABASE_URL",
                            "valueFrom": {
                            "secretKeyRef": {
                                "name": "app-secrets",
                                "key": "DATABASE_URL",
                                "optional": true
                            }
                            }
                        },
                        {
                            "name": "PGPASSWORD",
                            "valueFrom": {
                            "secretKeyRef": {
                                "name": "generated-secrets",
                                "key": "GENERATED_DB_PASSWORD",
                                "optional": true
                            }
                            }
                        },
                        {
                            "name": "PGPASSWORD",
                            "valueFrom": {
                            "secretKeyRef": {
                                "name": "$NAMESPACE",
                                "key": "DB_PASSWORD",
                                "optional": true
                            }
                            }
                        },
                        {
                            "name": "PGPASSWORD",
                            "valueFrom": {
                            "secretKeyRef": {
                                "name": "$NAMESPACE",
                                "key": "DATABASE_PASSWORD",
                                "optional": true
                            }
                            }
                        }
                        ],
                        "securityContext": {
                        "capabilities": {
                            "drop": ["ALL"]
                        }
                        }
                    }],
                    "imagePullSecrets": [{
                        "name": "private-registry"
                    }]
                    }
                }' \
                --command -- bash &
            ''
            ];
        };
        mysql-client = {
            shortCut = "Shift-2";
            description = "mysql-client";
            scopes = [ "pods" ];
            command = "sh";
            background = true;
            args = [
            "-c"
            ''
                kubectl run -it -n $NAMESPACE mysql-client \
                --image=registry1.dso.mil/ironbank/opensource/mysql/mysql8:8.0.29 \
                --overrides='{
                    "apiVersion": "v1",
                    "spec": {
                    "containers": [{
                        "name": "mysql-client",
                        "image": "registry1.dso.mil/ironbank/opensource/mysql/mysql8:8.0.29",
                        "command": ["/bin/bash"],
                        "args": ["-c", "sleep 1800"],
                        "serviceAccount": "default",
                        "env": [
                        {
                            "name": "MYSQL_PASSWORD",
                            "valueFrom": {
                            "secretKeyRef": {
                                "name": "$NAMESPACE",
                                "key": "MYSQL_PASSWORD",
                                "optional": true
                            }
                            }
                        },
                        {
                            "name": "MYSQL_USER",
                            "value": "DBAdmin"
                        }
                        ],
                        "securityContext": {
                        "capabilities": {
                            "drop": ["ALL"]
                        }
                        }
                    }],
                    "imagePullSecrets": [{
                        "name": "private-registry"
                    }]
                    }
                }' \
                --command -- bash &
            ''
            ];
        };
        };
    };
}

