# DFOC – Deterministic Finite Automata Description Language

DFOC is a domain-specific language (DSL) designed to describe and visualize **Deterministic Finite Automata (DFA)**. Users can define the components of a DFA using DFOC's syntax, and the language processes the description to generate a visual representation of the automaton.

The project demonstrates the use of compiler construction concepts, including lexical analysis, syntax analysis, and semantic validation, through the integration of **Flex** and **Bison**.

## Features

- **DFA Description:** Define automata using DFOC's domain-specific syntax.
- **Lexical Analysis:** Tokenize input descriptions using Flex.
- **Syntax Analysis:** Validate the structure of descriptions using Bison.
- **Semantic Validation:** Verify the consistency of DFA definitions.
- **Visualization:** Generate visual representations of the defined automata.
- **IDE:** Interact with the language through a browser-based development environment.

## Prerequisites

DFOC must be run in a Linux environment. Windows users can use Windows Subsystem for Linux (WSL2).

Ensure the following dependencies are installed:

- Linux environment (native Linux, virtual machine, or WSL2)
- GCC compiler
- Make
- Flex
- Bison
- Python 3

## Installation and Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Install Dependencies

On Ubuntu or Debian-based distributions:

```bash
sudo apt update
sudo apt install build-essential flex bison python3
```

### 3. Generate the Lexical and Syntax Analyzers

DFOC uses Flex and Bison to generate its lexical and syntax analyzers from their respective source files.

Run the following command from the project root directory:

```bash
./Makefile
```

This executes the commands defined in the project's `Makefile` and generates the required analyzer files.

### 4. Start the IDE

After successfully generating the analyzers, start the Python web server:

```bash
python3 updatedserver.py
```

### 5. Access the IDE

Open your browser and navigate to:

```text
http://localhost:8000
```

The DFOC IDE should now be accessible.

## Project Structure

The project consists of the following major components:

| Component | Description |
|---|---|
| Flex source file | Defines the lexical rules for tokenizing DFOC input. |
| Bison source file | Defines the grammar and syntax rules of the language. |
| Makefile | Automates the generation and compilation of the analyzers. |
| Python server | Hosts the browser-based IDE. |
| IDE | Provides the interface for writing and processing DFOC descriptions. |

*Note: Update this section to reflect the actual filenames and directory structure of the repository.*

## Usage

1. Launch the DFOC IDE by following the setup instructions.
2. Open the IDE in your browser.
3. Write a DFA description using the DFOC language syntax.
4. Submit the description for processing.
5. View the resulting DFA visualization.

## Technologies Used

- **C** – Core implementation of the language.
- **Flex** – Lexical analyzer generation.
- **Bison** – Syntax analyzer generation.
- **Python** – Web server implementation.
- **HTML, CSS, JavaScript** – Browser-based IDE interface.

## Academic Context

DFOC was developed as an academic project to explore the principles of compiler construction and formal language theory. It applies concepts such as lexical analysis, parsing, semantic validation, and finite automata representation in the development of a functional domain-specific language.

