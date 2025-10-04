# CA1 — Version Control with Git
**Base Application:** [Spring Petclinic](https://github.com/spring-projects/spring-petclinic)
**Course:** Configuration and Systems Management (COGSI)
**Institution:** ISEP — Master’s in Computer Engineering

---

## 1. Objective

The goal of this project is to **apply version control concepts using Git** in practice, based on the **Spring Petclinic** application.
The work is divided into **two parts**:
1. **Part 1:** development without branches
2. **Part 2:** development with branches


---

## 2. Environment Setup

### 2.1 Git Configuration (slides T2)
```bash
git config --global user.name "Student Name"
git config --global user.email "email@domain.com"
git config --global core.editor nano
git config --global init.defaultBranch main
git config -l
````

### 2.2 Clone the base repository

```bash
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
```


```bash
rm -rf .git
```

### 2.3 Initialize the CA1 repository

```bash
mkdir CA1
cd CA1
git init
git add .
git commit -m "Initial commit for CA1 - Spring Petclinic"
git branch -M main
git remote add origin https://github.com/<user>/cogsi2526-xxxxxx.git
git push -u origin main
```

---

## 3. Part 1 — Development **without branches**

### 3.1 Create initial tag (version 1.1.0)

```bash
git tag v1.1.0
git push origin main --tags
```

### 3.2 Add new feature: `professionalLicenseNumber` field

Edit the `Vet.java` class:

```java
private String professionalLicenseNumber;
```

Add the getter, setter, and update the JSP files.

Run and test:

```bash
./mvnw -DskipTests jetty:run-war
```

After confirming functionality:

```bash
git add .
git commit -m "Add professionalLicenseNumber field to Vet entity"
git tag v1.2.0
git push origin main --tags
```

### 3.3 Explore commit history

```bash
git log
```

### 3.4 Revert changes (slides T2)

```bash
git revert <commit-hash>
```

### 3.5 Final tag for part 1

```bash
git tag ca1-part1
git push origin main --tags
```

---

## 4. Part 2 — Development **with branches**

### 4.1 Create a new feature branch `email-field`

```bash
git switch email-field
```

Add a new `email` field to the `Vet.java` class and update related files.

```bash
git add .
git commit -m "Add email field to Vet entity"
git push -u origin email-field
```

### 4.2 Merge the branch into main

```bash
git switch main
git merge --no-ff email-field
git tag v1.3.0
git push origin main --tags
```

### 4.3 Simulate and resolve conflicts

```bash
git switch -c conflicting-edit
# Edit the same file modified in the previous branch (e.g., Vet.java)
git commit -am "Conflicting change on Vet entity"
git switch main
git merge conflicting-edit
# Manually resolve conflicts
git add .
git commit -m "Resolve merge conflict between email-field and conflicting-edit"
```

### 4.4 View branch tracking

```bash
git branch -vv
```

### 4.5 Final tag for part 2

```bash
git tag ca1-part2
git push origin main --tags
```

---

## 5. Self-Assessment of Contributions

| Member           | ID      | Contribution (%) |
| ---------------- | ------- | ---------------- |
| Sofia Marques    | 1250559 | 33.3%            |
| Alexandre Vieira | 1211551 | 33.3%            |
| Bárbara Silva    | 1250497 | 33.3%            |

---

## 6. Alternatives to Git and GitHub

This section analyzes **alternative tools** to Git and GitHub, discussing their **models**, **advantages** and **limitations**.

---

### 6.1 Alternatives to Git — Version Control Systems

| Tool                        | Type               | Description                                                                          | Advantages                                                                                               | Disadvantages                                                                                                          |
| --------------------------- | ------------------ | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Mercurial (hg)**          | Distributed (DVCS) | Similar to Git, with more consistent commands and a smoother learning curve.         | - Simpler, less error-prone interface<br>- Linear workflow<br>- Clean history                            | - Smaller community and support<br>- Limited integration with modern platforms                                         |
| **Apache Subversion (SVN)** | Centralized (CVCS) | Classic model with a single central repository and sequential history.               | - Centralized and predictable control<br>- Simpler for small teams<br>- Linear and easy-to-audit history | - No offline support<br>- Less flexible in collaborative environments<br>- Harder to manage multiple parallel versions |
| **Bazaar (bzr)**            | Distributed        | Created by Canonical (Ubuntu), focused on simplicity and integration with Launchpad. | - Easy to learn<br>- User-friendly interface<br>- Integrated with Launchpad                              | - Development discontinued<br>- Largely inactive community                                                             |

> **Summary:**
> Git remains the most flexible and widely supported system, while **Mercurial** offers simplicity and **SVN** is suitable for corporate environments requiring centralized control.
