ARG JENKINS_VERSION=2.568.2-lts-jdk21
FROM jenkins/jenkins:${JENKINS_VERSION}

ARG KUBECTL_VERSION=v1.36.1
USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git jq \
 && curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/$(dpkg --print-architecture)/kubectl" -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && case "$(dpkg --print-architecture)" in amd64) docker_arch=x86_64 ;; arm64) docker_arch=aarch64 ;; *) exit 1 ;; esac \
 && curl -fsSL "https://download.docker.com/linux/static/stable/${docker_arch}/docker-28.5.2.tgz" -o /tmp/docker.tgz \
 && tar -xzf /tmp/docker.tgz -C /tmp \
 && mv /tmp/docker/docker /usr/local/bin/docker \
 && rm -rf /var/lib/apt/lists/* /tmp/docker /tmp/docker.tgz
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins casc/ /var/jenkins_home/casc_configs/
COPY --chown=jenkins:jenkins job-dsl/ /var/jenkins_home/casc_configs/job-dsl/
USER jenkins
