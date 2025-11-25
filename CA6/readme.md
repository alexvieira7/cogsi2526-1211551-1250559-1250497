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
