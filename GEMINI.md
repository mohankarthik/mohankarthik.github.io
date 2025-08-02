# Gemini Project Companion: Mohan Karthik's 
This document provides context about the `mohankarthik/mohankarthik.github.io` repository for the Gemini AI assistant.

## Project Overview

This is a personal blog built with Jekyll and hosted on GitHub Pages. The blog focuses on topics related to technology, software development, leadership, and work-life balance.

**Key Technologies:**
*   **Jekyll:** The static site generator used for the blog.
*   **Ruby/Bundler:** Dependencies are managed via `Gemfile`.
*   **Minimal Mistakes Theme:** The blog uses the "minimal-mistakes" Jekyll theme.
*   **GitHub Pages:** The site is hosted directly from the GitHub repository.
*   **Markdown:** Blog posts are written in Markdown format.

## Content & Style

*   **Primary Topics:**
    *   Software Engineering (e.g., Machine Learning, CI/CD, Automotive Networks)
    *   Leadership & Productivity (e.g., Setting Boundaries, Focus)
    *   Personal Philosophy & Work-Life Balance
*   **Tone:** The writing style is personal, reflective, and often includes anecdotes to illustrate points. It aims to be practical and helpful.
*   **Post Structure:** Posts are located in the `_posts` directory with the filename format `YYYY-MM-DD-title.md`. They include YAML front matter for metadata like `layout`, `title`, `date`, `categories`, and `tags`.

## Repository Conventions

*   **Images:** Images for posts are stored in `assets/images/YYYY-MM-DD/`. There is a helper script `scripts/webp_convert.sh` which suggests a workflow for converting and managing images.
*   **Drafts:** Unfinished posts are kept in the `_drafts` directory.
*   **Configuration:** The main site configuration is in `_config.yml`. Navigation is managed in `_data/navigation.yml`.

## Common Tasks

*   **Creating a new post:**
    1.  Create a new file in `_posts` with the format `YYYY-MM-DD-your-post-title.md`.
    2.  Add the necessary YAML front matter.
    3.  Write the content in Markdown.
    4.  If adding images, place them in a corresponding `assets/images/YYYY-MM-DD` folder and consider using the `webp_convert.sh` script for optimization.
*   **Running locally:** (Assuming standard Jekyll setup) `bundle exec jekyll serve`

## Next set of topics
* The Art of the NACK: An Ode to I2C
* Cache and DMA. A match made in hell
* Reproducibility: The Cornerstone of Effective Debugging
* Engineering Is the Scientific Method, Fueled by Perseverance
* The Maintainability Tightrope: Writing Code for Your Future Self
* Why I'll never touch another untyped language (even for a quick and dirty script)
* Posture and Pain: The Physical Toll of a Programming Career
* Why the Most Effective Engineers I Know Are Kind
* Respect the Person, Challenge the Idea
* "Killer packets": Clock recovery on the wire!
