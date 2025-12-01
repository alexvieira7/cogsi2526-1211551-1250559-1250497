# **CA6 – CI/CD Pipelines (Jenkins)**

## **Objectives**

The objective of this assignment is to design and implement automated **CI/CD pipelines** using **Jenkins**, integrating build, testing, artifact management, and deployment processes for the Spring Boot application.

CA6 is divided into **two main parts and one alternative**:

* **Part 1:** Creation of a Jenkins pipeline that builds and tests the application, manages artifacts, and deploys it to Vagrant-provisioned VMs using Ansible, including approval steps, tagging, health checks, and rollback automation.

* **Part 2:** Extension of the pipeline to build and publish Docker images to Docker Hub, run tests in parallel, and deploy the containerized application to a production VM.

* **Alternative:** Design and analysis of an equivalent CI/CD solution using another automation tool, comparing it with Jenkins.

---

# **Comparative Analysis: CI/CD Orchestration Tools (Jenkins and Alternatives)**

Modern software delivery relies heavily on **automation pipelines**, enabling teams to continuously integrate and continuously deliver software with quality and speed.
For CA6, Jenkins is used as the primary CI/CD tool , but several alternative tools exist, each with different architectures, workflows, and strengths.

This analysis compares **Jenkins**, **GitHub Actions**, **GitLab CI/CD**, **Azure DevOps Pipelines**, and **Tekton**, focusing on architecture, extensibility, pipeline definitions, ecosystem, and ideal use cases.
The goal is to understand how Jenkins fits into the CI/CD space and how an alternative could also meet CA6's requirements.

---

# **Jenkins**

**Jenkins** is one of the most widely used open-source CI/CD automation servers. Its architecture is based on a **centralized server with agents** that execute jobs, and pipelines are defined via **Jenkinsfiles** — exactly what CA6 requires .

It is highly extensible thanks to 1800+ plugins and can interact with virtually any development tool, build system, SCM, or deployment platform.

### **Advantages**

* Completely open-source and highly customizable.
* Huge plugin ecosystem — supports any technology stack.
* Mature support for pipeline-as-code (`Jenkinsfile`), as required in CA6.
* Supports distributed builds across multiple agents.
* Highly flexible for DevOps, on-premise, or private infrastructure.

### **Shortcomings**

* Requires maintenance of the Jenkins master and agents.
* UI and configuration can feel dated compared to modern cloud-native tools.
* Plugin dependency issues may occur.
* Security requires careful configuration.

**Best suited for**: customizable pipelines, on-premise automation, heterogeneous environments, and academic environments where full control is required (e.g., CA6).

---

# **GitHub Actions**

**GitHub Actions** is GitHub’s built-in CI/CD system, tightly integrated with repositories.
Workflows run in hosted runners (or self-hosted ones) and are defined using YAML files.

### **Advantages**

* Native GitHub integration — triggers on pushes, pull requests, tags, etc.
* Zero server maintenance (fully SaaS).
* Marketplace with thousands of reusable actions.
* Extremely easy to set up.
* Free minutes for students.

### **Shortcomings**

* Limited customizability compared to Jenkins.
* Hosted runners may impose restrictions (timeouts, networking rules).
* Running complex infrastructure provisioning (e.g., Vagrant + Ansible) may be more difficult.
* Vendor lock-in.

**Best suited for**: GitHub-based development, lightweight container builds, cloud-native pipelines, fast automation.

---

# **GitLab CI/CD**

GitLab provides a built-in CI/CD module integrated into the GitLab ecosystem.
Similar to GitHub Actions, pipelines are defined in YAML (`.gitlab-ci.yml`).

### **Advantages**

* Deep integration with GitLab’s issue tracking, repositories, and deployments.
* Auto DevOps features.
* Docker-based runners simplify containerized builds.
* Very easy setup with rich UI feedback.

### **Shortcomings**

* Requires GitLab (cloud or self-hosted).
* More opinionated than Jenkins; less flexible for non-container workloads.
* Infrastructure automation sometimes harder than with Jenkins.

**Best suited for**: organizations using GitLab as their main DevOps platform.

---

# **Azure DevOps Pipelines**

Microsoft’s enterprise CI/CD tool, supporting YAML pipelines and complex enterprise workflows.

### **Advantages**

* Enterprise-grade features for large organizations.
* Integrated boards, repos, pipelines, test plans, and artifacts.
* Good support for containerized builds and deployments.
* Many hosted agent options.

### **Shortcomings**

* Complexity is high.
* Not ideal for small student projects.
* Best features require paid plans.

**Best suited for**: large companies with Microsoft-based workflows.

---

# **Tekton**

Tekton is a *cloud-native* CI/CD framework built on Kubernetes.
Instead of servers/agents, Tekton uses **Kubernetes CRDs** to run tasks, pipelines, and workspaces.

### **Advantages**

* Fully Kubernetes-native.
* Highly modular and reusable pipeline components.
* Cloud-ready, scalable, modern architecture.
* Vendor-neutral (part of the CD Foundation).

### **Shortcomings**

* Requires Kubernetes cluster — heavier to set up than Jenkins.
* Complex for beginners.
* Lacks the huge plugin ecosystem of Jenkins.

**Best suited for**: cloud-native teams running CI/CD entirely inside Kubernetes clusters.

---

# **Comparison Summary Table**

| Tool                | Architecture             | Ease of Setup | Extensibility | Best Use Case                  | Notes                                |
| ------------------- | ------------------------ | ------------- | ------------- | ------------------------------ | ------------------------------------ |
| **Jenkins**         | Server + agents          | Medium        | Very High     | Custom CI/CD, on-prem, CA6     | Plugin-rich but requires maintenance |
| **GitHub Actions**  | Cloud runners (SaaS)     | Very High     | High          | GitHub repos, container builds | Simplest option                      |
| **GitLab CI/CD**    | Integrated cloud/on-prem | High          | High          | GitLab-based DevOps            | Excellent integration                |
| **Azure Pipelines** | Cloud-hosted enterprise  | Medium        | High          | Corporate pipelines            | Enterprise-oriented                  |
| **Tekton**          | Kubernetes-native        | Low           | Medium-High   | Cloud-native CI/CD             | Requires Kubernetes                  |

---

# CA6 – Part 1

## CI/CD Pipeline with Jenkins, Vagrant, and Ansible

This technical report documents the analysis, design, and full implementation of **Part 1** of CA6.
The goal is to build a CI/CD pipeline that:

* Builds the Spring Boot Gradle application
* Runs tests and archives artifacts
* Requests manual approval
* Deploys the application to a *green* virtual machine
* Supports automated rollback
* Sets up infrastructure automatically using **Vagrant + Ansible**

---

# Project Structure (Actual Files)

Based on your repository:

![alt text](image/40.png)

---

# Architecture Overview

Part 1 uses a **Blue/Green Deployment** strategy with two VMs:

| VM    | IP            | Purpose                                     |
| ----- | ------------- | ------------------------------------------- |
| blue  | 192.168.56.10 | Hosts the initial application version       |
| green | 192.168.56.11 | Target for deployments triggered by Jenkins |

These machines are defined in the Ansible inventory:

![alt text](image/41.png)

---

# Infrastructure Automation – Vagrant & Ansible

## Virtual Machine Setup (Vagrantfile)

The infrastructure for this assignment is composed of two virtual machines—**blue** and **green**—created and managed using Vagrant.
Both machines run *Ubuntu Focal 64* and share the same hardware configuration, but each one uses a different static private IP address to support the Blue/Green deployment strategy.

### Vagrantfile used:

![alt text](image/50.png)

## Base provisioning (Java + service setup)

The `provision.yml` playbook prepares both virtual machines (blue and green) with everything required to run the Spring Boot application. It performs three essential actions:

1. **System Preparation** – Updates the APT package index to ensure all dependencies are retrieved from the latest repositories.
2. **Java Installation** – Installs **OpenJDK 17**, the version required to run the Spring Boot application.
3. **Application Environment Setup** – Creates the `/opt/myapp` directory, where the JAR file will be deployed, and configures a **systemd service** (`myapp.service`) responsible for starting, stopping, and automatically restarting the application.

![alt text](image/42.png)

Using a systemd unit provides reliable lifecycle management, ensures the application runs on boot, and allows Jenkins deployments to control the service consistently.

Overall, this playbook guarantees that both VMs are fully provisioned and ready to receive new application versions through the CI/CD pipeline.

---

## Jenkins Pipeline (Jenkinsfile)

The CI/CD pipeline is implemented using a scripted Jenkinsfile stored in the repository.
Its purpose is to automate the compilation, testing, packaging, approval, deployment, and verification of the Spring Boot application into the *green* virtual machine.

The pipeline is composed of the following stages:

1. **Checkout** – Retrieves the most recent version of the code from the repository using Jenkins’ built-in SCM.

2. **Assemble** – Compiles the application using Gradle inside *spring-example*, producing the JAR artifact. Tests are skipped in this stage to keep compilation fast.

3. **Test** – Executes the integration tests (`integrationTest`) and publishes the results using the `junit` plugin, enabling Jenkins to detect failures.

4. **Archive** – Stores the generated JAR file in Jenkins as an artifact, enabling version traceability and future rollback.

5. **Deploy to Production?** – Introduces a manual approval step to decide whether the new version should be deployed to the *green* VM. The pipeline stops if the user selects **no**.

6. **Deploy** – Automatically builds the artifact download URL and invokes the Ansible playbook `deploy-green.yml` to deploy the new version onto the green machine.
   It passes the artifact URL and inventory file as parameters.

7. **Verify Deployment** – Runs the `healthcheck.sh` script to ensure the application is running correctly after deployment.

```yaml
pipeline {

    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Assemble') {
            steps {
                dir('CA6/CA6-part1/spring-example') {
                    sh 'chmod +x gradlew || true'
                    sh './gradlew clean build -x test'
                }
            }
        }

        stage('Test') {
            steps {
                dir('CA6/CA6-part1/spring-example') {
                    sh './gradlew integrationTest'
                    junit 'build/test-results/integrationTest/*.xml'
                }
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'CA6/CA6-part1/spring-example/build/libs/*.jar', fingerprint: true
            }
        }

        stage('Deploy to Production?') {
            steps {
                script {
                    def approval = input(
                        message: "Deploy to GREEN VM?",
                        parameters: [
                            choice(
                                name: 'confirm',
                                choices: "no\nyes",
                                description: 'Approve deployment?'
                            )
                        ]
                    )
                    if (approval == "no") {
                        error "Deployment aborted by user"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {

                    def artifact = sh(
                        script: "ls CA6/CA6-part1/spring-example/build/libs/*.jar | grep -v plain",
                        returnStdout: true
                    ).trim()

                    echo "Artifact encontrado: ${artifact}"

                    def artifactName = artifact.replace("CA6/CA6-part1/spring-example/build/libs/", "")

                    def jenkins_ip = "192.168.56.1"

                    def artifact_url = 
                        "http://${jenkins_ip}:8080/job/${env.JOB_NAME}/${env.BUILD_NUMBER}/artifact/CA6/CA6-part1/spring-example/build/libs/${artifactName}"

                    echo "Artifact URL: ${artifact_url}"

                    // Executar o Ansible
                    sh """
                    ansible-playbook CA6/CA6-part1/ansible/deploy-green.yml \
                        -i CA6/CA6-part1/inventory.ini \
                        -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" \
                        --extra-vars "artifact_url=${artifact_url}"
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "bash CA6/CA6-part1/scripts/healthcheck.sh"
            }
        }
    }


    post {
        success {
            echo 'Pipeline succeeded'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
```

Additionally, in the `post` section, the pipeline prints a final success or failure message depending on the result of the entire process.

This Jenkinsfile encapsulates the full CI/CD flow required for Part 1 of the assignment, including build automation, artifact handling, environment provisioning, deployment, and post-deployment validation.

---

# Deployment with Ansible

## Deployment with Ansible (`deploy-green.yml`)

The deployment process for the *green* virtual machine is fully automated through the `deploy-green.yml` playbook. It receives the `artifact_url` from Jenkins and performs the necessary steps to safely replace the running application with the newly built version.

### **What the playbook does**

1. **Stops the currently running service** (`myapp`) to ensure the old JAR file is not in use.
2. **Ensures the deployment directory exists** (`/opt/myapp`), making the playbook idempotent.
3. **Downloads the new artifact from Jenkins** and places it as `/opt/myapp/app.jar`.
4. **Reloads systemd**, making sure it recognizes any updated service definitions.
5. **Starts the application service**, ensuring it automatically restarts on failures.
6. **Performs an HTTP healthcheck** on `http://localhost:8080` to confirm the application started successfully.

This logic is implemented as follows:

![alt text](image/43.png)

---

### **Why this design?**

* **Dynamic deployment from Jenkins**: Passing `artifact_url` ensures Jenkins controls exactly which version is deployed, enabling reproducibility and traceability.
* **Safe and idempotent**: The playbook can be executed multiple times without breaking the environment.
* **Robust startup validation**: Accepting HTTP codes **200 or 404** ensures the application is running even if routes are not fully initialized yet.
* **Service-based deployment**: Using systemd provides reliability, restarts on failure, and simplifies lifecycle management.

---

## ✔ Healthcheck Script (`healthcheck.sh`)

After the deployment stage, the pipeline validates whether the application running on the **green** VM has started successfully.
This verification is performed by the script `healthcheck.sh`, which sends an HTTP request to the application and checks the returned status code.

The script performs the following steps:

1. Targets the green VM at `192.168.56.11`.
2. Sends a silent `curl` request to `http://GREEN_IP:8080`.
3. Extracts only the HTTP status code returned by the application.
4. Considers the deployment **healthy** if the status code is either **200** (OK) or **404** (application running but endpoint not found).
5. Fails the pipeline otherwise.

This behavior ensures that the Spring Boot server is running even if the REST endpoints are not fully initialized yet.

### Script used in the repository:

![alt text](image/44.png)

### Why this approach?

* **Reliable detection**: `curl` ensures the service is answering requests.
* **Flexible validation**: Accepting `200` and `404` avoids false negatives during early Spring Boot initialization.
* **Integration with Jenkins**: A non-zero exit code automatically marks the deployment as failed, enabling rollback if needed.

---

## Rollback Mechanism (`rollback.yml`)

The rollback process provides a safe recovery path whenever a deployment fails or the post-deployment healthcheck detects an issue.
Jenkins triggers this operation by supplying a `rollback_url`, which points to a previously tagged **stable** artifact stored in Jenkins.

The `rollback.yml` playbook performs three simple and reliable steps:

1. **Stop the running service** to ensure the faulty version is no longer active.
2. **Download the stable artifact** from Jenkins and overwrite the current `app.jar` in `/opt/myapp`.
3. **Restart the application service**, restoring the last known good version.

### Playbook used in the project:

![alt text](image/45.png)

### Why this design?

* **Fast recovery**: The rollback only replaces the JAR and restarts the service — no re-provisioning required.
* **Guaranteed stability**: Artifacts tagged as *stable* ensure only verified versions are restored.
* **Pipeline integration**: Jenkins supplies the correct artifact URL automatically, making the rollback deterministic and repeatable.

This mechanism ensures reliable and consistent recovery from faulty deployments, which is an essential requirement for modern CI/CD pipelines.

---

# Step-by-Step Reproduction Guide

Below is the complete step-by-step process to reproduce and validate the CI/CD workflow, including screenshots proving that the pipeline, deployment, and application all work correctly.

---

## 1. Start the virtual machines

```
vagrant up
```

---

## 2. Provision both blue and green environments

```
ansible-playbook -i ansible/inventory.ini ansible/provision.yml
```

---

## 3. Run the Jenkins pipeline

Jenkins executes:

**Checkout → Build → Test → Archive → Deploy → Verify Deployment**

![alt text](image/46.png)

---

## 4. Artifact generated and archived in Jenkins

The build produces two JAR files, and Jenkins archives the correct deployable artifact:

![alt text](image/47.png)

This confirms that the application was compiled correctly and the JAR is available for deployment and rollback.

---

## 5. Verify the deployment on the GREEN VM

After deploying, you can confirm that the Spring Boot service is running by checking the HTTP response:

![alt text](image/48.png)

This matches the healthcheck logic used in the pipeline.

---

## 6. Confirm artifact download inside the VM

You can also verify that the GREEN VM successfully downloaded the artifact from Jenkins by inspecting the HTTP headers:

![alt text](image/49.png)

The `200 OK`, `application/java-archive`, and `Content-Length` confirm the JAR was downloaded correctly.

---

## 7. If needed, perform a rollback

```
ansible-playbook -i ansible/inventory.ini ansible/rollback.yml
```

The rollback playbook replaces the current JAR with a stable version previously stored in Jenkins.

---

# Alternative with GitHub Actions (Blue/Green + Rollback) - Part 1

## Objective

This CA6 alternative replaces Jenkins with **GitHub Actions** to implement:

* **CI/CD** pipeline for the Spring Boot application (`CA6/spring-example`)
* **Blue/Green Deployment** using Vagrant + Ansible
* **Automatic Rollback** to a stable tagged version (`stable-vX`)

> **Note:** The repository had to be made public in order to use GitHub Actions for this alternative, as some features (such as self-hosted runners and artifact handling) were required for the CI/CD workflow.

---

## Project File Structure

![alt text](image/1.png)

![alt text](image/2.png)

---

## Infrastructure (Vagrant + Blue/Green)

![alt text](image/17.png)

The file `CA6/alternativa/Vagrantfile` creates two Ubuntu VMs using VirtualBox:

* **blue** – IP: `192.168.56.10`
* **green** – IP: `192.168.56.11`

First command is:

![alt text](image/3.png)

The Vagrant-generated private keys are stored in:

```text
CA6/alternativa/.vagrant/machines/*/virtualbox/private_key
```

Ansible uses these keys (configured in `inventory.ini`) to SSH from the self-hosted runner.


To test if the VMs are working we use this command:

![alt text](image/12.png)

---

## Provisioning with Ansible

### Inventory (`ansible/inventory.ini`)

Simplified example:

![alt text](image/4.png)

> The `private_key` paths are **absolute paths** on the host running the self-hosted runner.

---

## Deployment (`ansible/deploy.yml`)

This playbook automates the deployment of the Spring Boot application on the virtual machines. It installs the required runtime, deploys the JAR, configures the application as a system service, and validates that the API is running correctly.

---

## Environment Setup (Java + App Directory)

The playbook begins by installing **Java 17**, which is required for running the Spring Boot application.
It then creates the `/opt/app` directory where the application will be stored.

![alt text](image/16.png)

---

## Deploying the Application (Copy JAR + systemd Service)

Next, the built JAR file is copied to the target machine.
A `systemd` service file (`app.service`) is created so the application runs as a managed background service and restarts automatically if it stops.

![alt text](image/15.png)

After creating the service, systemd is reloaded and the application is started and enabled at boot.

![alt text](image/14.png)

---

## Application Health Check

To ensure the application is running correctly, the playbook waits for port **8080** to become available and then performs a simple HTTP request to the `/employees` endpoint.
If the endpoint returns **200 OK**, the deployment is considered successful.

![alt text](image/13.png)

Deployment runs only on the **green** VM:

![alt text](image/5.png)

---

## Self-hosted Runner

Runner was configured at:

```text
/home/user/actions-runner
```

Using:

![alt text](image/9.png)

![alt text](image/10.png)

Workflow uses:

![alt text](image/11.png)

This allows GitHub Actions to:

* access the Vagrant VMs (network `192.168.56.x`)
* use Ansible and Vagrant SSH keys available on the machine

---

## GitHub Actions – CI/CD (`.github/workflows/ci-cd.yml`)

This workflow defines a full **CI/CD pipeline** for the Spring Boot application in `CA6/spring-example`, running on a **self-hosted runner**.

It is split into two jobs:

* **`build-test`** → Continuous Integration (build + tests + artifact)
* **`deploy`** → Continuous Deployment (deploy to GREEN + health check + tagging + rollback artifact)

---

### Trigger

The pipeline runs automatically on every `push` to the **`main`** branch:

![alt text](image/6.png)

This ensures that every change merged into `main` is built, tested, and (if successful) deployed.

---

### CI: `build-test` Job

The **`build-test`** job is responsible for the **Continuous Integration** part: compiling the project, running tests, and publishing the build artifact.

It runs on the **self-hosted runner**:

![alt text](image/23.png)

### Steps (CI – `build-test` job)

The pipeline checks out the repository, installs JDK 17, builds the Spring Boot project, runs the tests, and finally uploads the generated JAR as an artifact for the deployment stage. If any of these steps fail, the workflow stops and no deployment occurs.

![alt text](image/24.png)

If any of these steps fail (build or tests), the pipeline stops and the application is **not deployed**.

---

### CD: `deploy` Job

The **`deploy`** job handles the **Continuous Deployment** part.
It only runs **if `build-test` succeeds**:

![alt text](image/22.png)

Main steps:

**Checkout repository and Download artifact**

Retrieves the JAR artifact created in the `build-test` job.

![alt text](image/21.png)


**Normalize JAR name**

   Picks the correct executable JAR (excluding `-plain`) and renames it to `app.jar`, which is what the Ansible playbook expects.

   ![alt text](image/20.png)

**Deploy to GREEN with Ansible and Health check from runner**

   Calls the Ansible playbook (`ansible/deploy.yml`) to deploy the application to the **GREEN** environment and verifies from the runner that the application is reachable and responding correctly on the `/employees` endpoint.

   ![alt text](image/19.png)

**Create stable tag and save artifact for rollback**

   If deployment succeeds:

   * creates a **tag** like `stable-v<run_number>` and pushes it to the repository
   * saves a copy of the deployed JAR in `CA6/alternativa/artifacts/` for **rollback** purposes.

   ![alt text](image/18.png)

---

## CI Execution on Commit

Whenever a new **commit is pushed to the `main` branch**, GitHub Actions automatically triggers the **CI stage** of the pipeline. This ensures that every change is immediately validated by compiling the project, running tests, and generating the application artifact.

If all steps complete successfully, the workflow shows a green **“Success”** status in GitHub Actions, confirming that the code is stable and ready for deployment.

![alt text](image/25.png)

---

Here’s a polished version of the **Rollback** section, already adapted to match the **GitHub Actions rollback workflow** you sent.

---

# **Rollback Mechanism (GitHub Actions + Ansible)**

## Rollback to Stable Versions (`stable-vX`)

In addition to the CI/CD pipeline and Blue/Green deployment strategy, this project implements a **rollback mechanism** that allows reverting to a previously stable version using:

* GitHub Actions
* Ansible
* Vagrant (Green VM)
* Stable version tags (`stable-v1`, `stable-v2`, …)

Every successful deployment to the **green** environment creates a new stable tag, for example:

```text
stable-v1, stable-v2, stable-v3, ...
```

and stores the corresponding JAR file in:

```text
CA6/alternativa/artifacts/app-stable-vX.jar
```

These stored artifacts are later used as rollback candidates.

---

## How the Rollback Workflow Works

The rollback is triggered manually through GitHub Actions using `workflow_dispatch`, where the user selects the stable tag to restore (e.g., `stable-v5`):

![alt text](image/26.png)

The `rollback` job runs on the self-hosted runner and performs three essential steps:

**Checkout the repository and Verify the rollback artifact**
Retrieves the repository with full history (required for tags) and without cleaning the workspace. Ensures that the JAR for the selected tag exists. If not, the workflow stops.

![alt text](image/27.png)


**Run the Ansible rollback playbook**
Executes the rollback by replacing the current app JAR on the green VM and restarting the service.

![alt text](image/28.png)

The Ansible playbook stops the running service, deploys the selected stable JAR, restarts the application, waits for it to start, and performs an HTTP health-check.
If the check fails, GitHub Actions reports an error and the rollback is not applied.

---

## Rollback Playbook (`ansible/rollback.yml`)

Location:

```
CA6/alternativa/ansible/rollback.yml
```

The playbook performs:

* stop the current Spring Boot service
* copy the stable JAR to `/opt/app/app.jar`
* restart the service using `systemd`
* wait for port **8080** to become available
* perform a final health-check

Simplified version:

![alt text](image/7.png)

This ensures the application actually starts before performing the verification.

---

## Rollback Workflow (GitHub Actions)

The rollback workflow is located at:

```
.github/workflows/rollback.yml
```

and is triggered manually using:

```
Actions → CA6 Part1 Rollback → Run workflow
```

The user must provide a stable tag (e.g., `stable-v6`).
The workflow then performs:

1. Repository checkout
2. Validation that the artifact `app-stable-vX.jar` exists
3. Execution of the rollback Ansible playbook
4. Final verification (health-check)

![alt text](image/8.png)

Thanks to the artifacts stored on the self-hosted runner, **rollback does not rebuild the application**—it simply switches to a previously validated version.

---

# Alternative with GitHub Actions - Part 2

GitHub Actions + Docker + Vagrant + Ansible**

## **1. Objective**

This alternative replaces Jenkins (from the official CA6-Part2 instructions) with a pure **GitHub Actions CI/CD pipeline** using:

* **Docker** (containerization of the Spring Boot app)
* **Docker Hub** (image registry)
* **Vagrant + VirtualBox** (production VM)
* **Ansible** (container deployment automation)

The workflow automatically:

1. Runs unit + integration tests
2. Builds a JAR
3. Builds and pushes a Docker image
4. Deploys and runs the container inside a Vagrant VM
5. Performs an automated health check

---

## **2. Project Structure (Part 2)**

![alt text](image/38.png)

---

## **Infrastructure Setup (Vagrant)**

The file:

```
CA6/alternativa-part2/Vagrantfile
```

![alt text](image/37.png)

Creates a VM named **production**, with:

* IP: `192.168.57.10`
* Ubuntu 20.04
* automatic provisioning (apt update)

### Start the VM

```bash
vagrant up
```

Check status:

![alt text](image/36.png)

SSH inside:

```bash
vagrant ssh production
```

---

## **Ansible Configuration**

### **Inventory file**

```
CA6/alternativa-part2/ansible/inventory.ini
```

Example:

![alt text](image/35.png)

### **Deployment Playbook (`deploy.yml`)**

This playbook:

1. Installs Docker
2. Logs in to Docker Hub
3. Pulls the latest image
4. Stops existing container (if any)
5. Runs the new container on port 8080
6. Waits for the service to start
7. Performs a health check

**File:** `CA6/alternativa-part2/ansible/deploy.yml`

![alt text](image/34.png)

---

## **GitHub Secrets Required**

Go to:

**GitHub → Repository → Settings → Secrets and variables → Actions**

Create:

| Secret name    | Description                           |
| -------------- | ------------------------------------- |
| `DOCKER_USER`  | Your Docker Hub username              |
| `DOCKER_PASS`  | Docker Hub password or access token   |
| `DOCKER_IMAGE` | Repository name (ex: `cogsi-ca6-app`) |

---

## **Dockerfile**

Located at:

```
CA6/spring-example/Dockerfile
```

Used to build the container:

![alt text](image/33.png)

---

## **GitHub Actions Workflow (CI/CD)**

File:

```
.github/workflows/ci-cd-part2.yml
```

The pipeline has **4 jobs**:

### ✔ 1. unit-tests

Runs standard Gradle tests.

### ✔ 2. integration-tests

Runs integration tests (same command as above, optional separation).

### ✔ 3. docker-build-push

Builds the app + Docker image and pushes to Docker Hub.

### ✔ 4. deploy

Runs Ansible to deploy the new container into the Vagrant VM.

---

### **Full CI/CD workflow**

```yaml
name: CA6 Part2 CI/CD (GitHub Actions)

on:
  push:
    branches: [ CA6-part2 ]

env:
  DOCKER_USER: ${{ secrets.DOCKER_USER }}
  DOCKER_PASS: ${{ secrets.DOCKER_PASS }}
  DOCKER_IMAGE: ${{ secrets.DOCKER_IMAGE }}

jobs:
  unit-tests:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17
      - run: ./gradlew test
        working-directory: CA6/spring-example

  integration-tests:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17
      - run: ./gradlew test
        working-directory: CA6/spring-example

  docker-build-push:
    runs-on: self-hosted
    needs: [unit-tests, integration-tests]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17

      - run: ./gradlew clean build
        working-directory: CA6/spring-example

      - name: Normalize JAR name
        working-directory: CA6/spring-example
        run: |
          JAR=$(ls build/libs/*SNAPSHOT.jar | grep -v plain | head -n 1)
          cp "$JAR" build/libs/app.jar

      - name: Login Docker Hub
        run: echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

      - name: Build Docker image
        working-directory: CA6/spring-example
        run: |
          docker build \
            -t $DOCKER_USER/$DOCKER_IMAGE:latest \
            -f ../alternativa-part2/docker/Dockerfile .

      - name: Push Docker image
        run: docker push $DOCKER_USER/$DOCKER_IMAGE:latest

  deploy:
    runs-on: self-hosted
    needs: docker-build-push
    steps:
      - uses: actions/checkout@v4
      - run: ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
        working-directory: CA6/alternativa-part2
```

---

## **How to Run the Entire Pipeline**

### **Start self-hosted runner**

![alt text](image/30.png)

![alt text](image/31.png)

### **Ensure the VM is running**

![alt text](image/32.png)

### **Push to the CA6-part2 branch**

```bash
git add .
git commit -m "CA6 Part2 working CI/CD"
git push origin CA6-part2
```

### **GitHub Actions triggers automatically**

Check in:

**GitHub → Actions → CA6 Part2 CI/CD**

All steps should become green ✔
The app becomes available at:

![alt text](image/39.png)

![alt text](image/29.png)

---

# Self-Assessment of Contributions

| Membro | ID | Contribuição (%) |
|---------|----|------------------|
| Sofia Marques | 1250559 | 33.3% |
| Alexandre Vieira | 1211551 | 33.3% |
| Bárbara Silva | 1250497 | 33.3% |


