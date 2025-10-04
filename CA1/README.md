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

## 6. Alternatives to Git

This section analyzes **alternative tools** to Git, discussing their **models**, **advantages** and **limitations**.

---

### 6.1 Alternatives to Git — Version Control Systems

| Tool                        | Type               | Description                                                                          | Advantages                                                                                               | Disadvantages                                                                                                          |
| --------------------------- | ------------------ | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Mercurial (hg)**          | Distributed (DVCS) | Similar to Git, with more consistent commands and a smoother learning curve.         | - Simpler, less error-prone interface<br>- Linear workflow<br>- Clean history                            | - Smaller community and support<br>- Limited integration with modern platforms                                         |
| **Apache Subversion (SVN)** | Centralized (CVCS) | Classic model with a single central repository and sequential history.               | - Centralized and predictable control<br>- Simpler for small teams<br>- Linear and easy-to-audit history | - No offline support<br>- Less flexible in collaborative environments<br>- Harder to manage multiple parallel versions |
| **Bazaar (bzr)**            | Distributed        | Created by Canonical (Ubuntu), focused on simplicity and integration with Launchpad. | - Easy to learn<br>- User-friendly interface<br>- Integrated with Launchpad                              | - Development discontinued<br>- Largely inactive community                                                             |

> **Summary:**
> Git remains the most flexible and widely supported system, while **Mercurial** offers simplicity and **SVN** is suitable for corporate environments requiring centralized control.

## 7. Alternative Tool - Mercurial

### 7.1 Configure Mercurial

Check that Mercurial is installed and set up your global identity:

```bash
hg --version
hg config --edit
```

Add or edit your configuration file (`~/.hgrc` or `Mercurial.ini` on Windows):

```ini
[ui]
username = Student Name <email@domain.com>
editor = nano
```

---

### 7.2 Get the Base Repository

You can either **start fresh** or **clone directly from GitHub** (if you have `hg-git` enabled).

#### Option A — Start fresh (recommended for CA1)

```bash
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
rm -rf .git
```

Now you have the project files without any Git metadata.

#### Option B — Clone directly using Mercurial (requires `hg-git`)

1. Enable the extension in your configuration:

   ```ini
   [extensions]
   hggit =
   ```
2. Clone the repository:

   ```bash
   hg clone git+https://github.com/spring-projects/spring-petclinic.git
   cd spring-petclinic
   ```

---

### 7.3 Initialize the CA1 Repository

```bash
mkdir -p CA1
mv * CA1/
cd CA1

hg init
hg addremove
hg commit -m "Initial commit for CA1 - Spring Petclinic"
```

(Optional) Set up a remote repository in `.hg/hgrc`:

```ini
[paths]
default = https://<your-username>@<your-hg-server>/cogsi2526-ca1
```

Push (if a remote exists):

```bash
hg push
```

---

## 8. Part 1 — Development **without branches**

All work is done on the default branch.

### 8.1 Create an initial tag (version 1.1.0)

```bash
hg tag v1.1.0
hg push
```

---

### 8.2 Add new feature: `professionalLicenseNumber` field

Edit the `Vet.java` class:

```java
private String professionalLicenseNumber;
```

Add the getter, setter, and update relevant templates.

Run and test:

```bash
./mvnw -DskipTests jetty:run-war
# or
./mvnw spring-boot:run
```

Commit your work:

```bash
hg addremove
hg commit -m "Add professionalLicenseNumber field to Vet entity"
hg tag v1.2.0
hg push
```

---

### 8.3 Explore commit history

```bash
hg log
hg log -G     # Graph view
hg log -l 10 -T "{rev}:{node|short} {author|person} {date|age} {desc|firstline}\n"
```

---

### 8.4 Revert changes

* Revert files to a previous revision:

  ```bash
  hg revert -r <rev> <file>
  ```
* Create a new commit that undoes a previous one:

  ```bash
  hg backout <rev>
  hg commit -m "Backout of revision <rev>"
  ```

---

### 8.5 Final tag for Part 1

```bash
hg tag ca1-part1
hg push
```

---

## 9. Part 2 — Development **with branches (bookmarks)**

> In Mercurial, you can use:
>
> * **Named branches**: permanent and stored in history
> * **Bookmarks**: lightweight, similar to Git branches
>   For this project, we’ll use **bookmarks**.

---

### 9.1 Create a new feature bookmark `email-field`

```bash
hg bookmark email-field
hg update email-field
```

Add a new `email` field to `Vet.java`, update templates, then commit:

```bash
hg addremove
hg commit -m "Add email field to Vet entity"
hg push
```

---

### 9.2 Merge the bookmark into `default`

```bash
hg update default
hg merge email-field
hg commit -m "Merge email-field into default"
hg tag v1.3.0
hg push
```

---

### 9.3 Simulate and resolve conflicts

```bash
hg bookmark conflicting-edit
hg update conflicting-edit
# Edit the same lines as before to create a conflict
hg commit -m "Conflicting change on Vet entity"

# Merge back into default
hg update default
hg merge conflicting-edit

# List conflicts
hg resolve -l

# Manually edit and mark as resolved
hg resolve -m path/to/conflicted/file.java

# Finalize merge
hg commit -m "Resolve merge conflict between email-field and conflicting-edit"
hg push
```

---

### 9.4 View repository and bookmarks

```bash
hg bookmarks      # List bookmarks (like Git branches)
hg paths          # Show remote repositories
hg incoming       # See what’s coming from remote
hg outgoing       # See what’s going to remote
```

---

### 9.5 Final tag for Part 2

```bash
hg tag ca1-part2
hg push
```

---