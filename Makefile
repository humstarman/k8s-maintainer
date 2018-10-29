LOCAL_REGISTRY="10.254.0.50:5000"
IMAGE_NAME="maintainer"
IMAGE_TAG="v1"
KUBE_API_SECURE_PORT="6443"
KUBE_API_INSECURE_PORT="8080"
KUBECTL_BINARY_PATH="/usr/local/bin/kubectl"
KUBECTL_CONFIG_PATH="/root/.kube"
NAME=${IMAGE_NAME}
NAMESPACE="default"
IMAGE=${LOCAL_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
IMAGE_PULL_POLICY=always
MANIFEST=./manifests

all: push deploy

build:
	@docker build -t ${IMAGE} .

push:
	@docker push ${IMAGE}

cp:
	@find ./manifests -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ./manifests -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ./manifests -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ./manifests -type f -name "*.yaml" | xargs sed -i s?"{{.port}}"?"${PORT}"?g
	@find ./manifests -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g
	@find ./manifests -type f -name "*.yaml" | xargs sed -i s?"{{.image.pull.policy}}"?"${IMAGE_PULL_POLICY}"?g


deploy: OP=${OP}
deploy: cp sed
	-@kubectl ${OP} -f ./manifest/namespace.yaml
	-@kubectl ${OP} -f ./manifest/service.yaml
	-@kubectl ${OP} -f ./manifest/ingress.yaml

clean: OP=delete
clean:
	-@kubectl ${OP} -f ./manifest/service.yaml
	-@kubectl ${OP} -f ./manifest/ingress.yaml
	-@kubectl ${OP} -f ./manifest/configmap.yaml
	-@kubectl ${OP} -f ./manifest/controller.yaml
	-@rm -f ./manifest/service.yaml
	-@rm -f ./manifest/ingress.yaml
	-@rm -f ./manifest/configmap.yaml
	-@rm -f ./manifest/controller.yaml
