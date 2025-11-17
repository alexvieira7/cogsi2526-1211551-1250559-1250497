# **CA5 – Containerization and Orchestration (Docker)**

## **Objectives**

The objective of this assignment is to understand and apply modern containerization technologies, focusing on **Docker**, and to compare its use with alternative container engines.

CA5 is divided into **two main parts and one alternative**:

* **Part 1:** Containerization of the applications developed in CA2/CA3, including the creation of Docker images (v1, v2, and multi-stage builds) and validation of containerized execution.

* **Part 2:** Deployment and orchestration of a multi-container environment (e.g., using Docker Compose), enabling coordinated execution and networking between services.

* **Alternative:** Implementation and analysis of an equivalent solution using another containerization or runtime tool as an alternative to Docker.

---

# Comparative Analysis: Docker and Containerization Alternatives

Modern application deployment relies heavily on **containerization**, and Docker has become the most widely adopted tool in this space.
However, several alternatives provide different architectures, features, and use cases.
This section provides an in-depth comparison between **Docker**, **Podman**, **containerd**, **CRI-O**, and **LXC/LXD**, examining how they differ in design, security, ecosystem, and typical scenarios.

---

# Docker

**Docker** is the most popular containerization platform, providing tools for building, running, and distributing containers.
Docker introduced a developer-friendly workflow, an opinionated ecosystem (Docker Engine, Docker CLI, Docker Compose, Docker Hub), and made containers mainstream.

Docker uses a **daemon-based architecture**, where the Docker Engine performs all container operations on behalf of the user.

### **Advantages:**

* Extremely **easy to use**, both for beginners and experts.
* Massive ecosystem: **Docker Hub**, Docker Compose, Docker Desktop.
* Strong community support and documentation.
* Works across Linux, macOS, and Windows.
* Integrates well with CI/CD systems and cloud providers.
* Mature tooling for building and distributing containerized applications.

### **Shortcomings:**

* Requires a **daemon running as root**, which may raise security concerns.
* Docker Engine is **not part of the Kubernetes CRI (Container Runtime Interface)**—Kubernetes now uses containerd/CRI-O by default.
* Memory and CPU usage can be higher compared to lightweight runtimes.
* Less suitable for extremely minimal or security-sensitive environments.

Docker remains the **de facto standard for development and testing**, and is widely used for local development, microservices, and DevOps workflows.

---

# Podman

**Podman** is a daemonless container engine developed by Red Hat.
It is compatible with Docker’s CLI (`podman run`, `podman build`, etc.) and can even alias as Docker.

Podman’s biggest distinction is its **rootless architecture**, which enhances security by eliminating the need for a privileged daemon.

### **Advantages:**

* **Daemonless and rootless**, providing a more secure environment.
* Supports **Docker-compatible commands and images**.
* Can manage “pods” natively, similar to Kubernetes.
* Integrates well with systemd for persistent services.
* Lighter footprint and improved security isolation.

### **Shortcomings:**

* Slightly steeper learning curve for users used to Docker’s workflows.
* Podman Compose (alternative to Docker Compose) is less mature.
* Smaller community compared to Docker.
* Less widespread adoption in non-Red Hat ecosystems.

Podman is ideal for **production servers**, **security-focused environments**, or when Docker’s root daemon is undesirable.

---

# containerd

**containerd** is a lightweight, high-performance runtime originally extracted from Docker.
It focuses solely on running containers and managing images, without orchestration or higher-level features.

Kubernetes uses containerd as its default runtime.

### **Advantages:**

* Very lightweight and optimized for performance.
* Directly compliant with the **Kubernetes CRI**.
* Mature, minimal, stable — ideal for cloud-native environments.
* Used internally by Docker itself.

### **Shortcomings:**

* Not intended for developers — lacks build tools, high-level CLI, or Compose-like features.
* Typically requires an orchestration layer to be useful (Kubernetes).

containerd is best suited for **Kubernetes clusters**, managed environments, or minimal container runtime setups.

---

# CRI-O

**CRI-O** is an OCI-compliant runtime purpose-built for Kubernetes.
It is extremely lightweight and secure, designed only to meet Kubernetes CRI requirements.

### **Advantages:**

* Minimal footprint — no unnecessary features.
* Highly secure and stable, widely used in enterprise Kubernetes distributions.
* Works seamlessly with Kubernetes without extra abstractions.

### **Shortcomings:**

* Not designed for Docker-like development workflows.
* Limited outside Kubernetes use cases.

CRI-O is the best choice for **production Kubernetes clusters**, especially in Red Hat/OpenShift environments.

---

# LXC / LXD

**LXC (Linux Containers)** and **LXD** provide OS-level virtualization, closer to lightweight virtual machines than application containers.

LXD provides a user-friendly interface on top of LXC, allowing full system containers.

### **Advantages:**

* Runs **full Linux OS containers**, not just applications.
* Better suited for system-level isolation or VM replacement.
* Strong networking and storage management capabilities.

### **Shortcomings:**

* Heavier than Docker-style containerization.
* Not meant for microservices or app-level deployment.
* Smaller community and ecosystem.

LXC/LXD is ideal for **system containers**, hosting multiple Linux OS instances, or replacing VMs with lightweight environments.

---

# Comparison Summary Table (sem coluna de estrelas)

| Tool           | Architecture       | Rootless | Kubernetes Support        | Best Use Case                                  | Notes                        |
| -------------- | ------------------ | -------- | ------------------------- | ---------------------------------------------- | ---------------------------- |
| **Docker**     | Daemon-based       | Partial  | Indirect (via containerd) | Development, CI/CD, microservices              | Easiest + largest ecosystem  |
| **Podman**     | Daemonless         | Yes      | Medium                    | Secure production servers, rootless containers | Docker-compatible            |
| **containerd** | Runtime-only       | Yes      | Native                    | Kubernetes clusters, cloud-native runtime      | Very lightweight             |
| **CRI-O**      | Runtime-only (K8s) | Yes      | Native                    | Enterprise Kubernetes deployments              | Purpose-built for Kubernetes |
| **LXC/LXD**    | System containers  | Yes      | Low                       | OS virtualization, VM replacement              | Full OS containers           |

---

# CA5 Part 1

## **Chat Application — Docker v1**

This document explains all the steps performed to run the chat server inside a Docker container, including the project structure, the Dockerfile, the commands used, and the technical issues encountered and solved during the process.

---

# Project Structure

The Part 1 folder contains two sub-directories:

![1.png](image/1.png)


The **`app`** folder contains the source code located in `src/main/java/basic_demo/...`, along with the Gradle configuration files (`build.gradle` and `settings.gradle`) and the Gradle Wrapper (`gradlew` and `gradlew.bat`).
The **`rest`** folder includes the `Dockerfile.v1` file, which is the Dockerfile used for the first version of the chat server container.


---

# Dockerfile.v1

The `Dockerfile.v1`, placed in `CA5/part1/rest/`, contains:

![2.png](image/2.png)

---

# Building the Docker Image

Within the `CA5/part1/` folder, we executed the command below:

![3.png](image/3.png)


Explanation:

* `-f rest/Dockerfile.v1` → tells Docker that the Dockerfile is inside `rest/`
* `app` → sets the **context**, so Docker copies the Java project into the container

The image built successfully:

![4.png](image/4.png)

---

# Running the Chat Server in Docker

Command:

![5.png](image/5.png)

This confirms:

* the container starts correctly
* the server runs automatically
* the port is exposed and mapped properly

---

# Testing the Client (on the host)

The client requires **Java 17** to run correctly, since the GUI (Swing) does not work properly with newer default JDK versions on some systems. 


![6.png](image/6.png)


![7.png](image/7.png)


The graphical window appeared, allowing:

* entering a screen name
* sending/receiving messages
* connecting to the server running inside Docker

---

# Additional Server Test (without GUI)

To confirm the server was listening:

![8.png](image/8.png)

![9.png](image/9.png)

Meaning the Docker container’s server is fully functional.

---

