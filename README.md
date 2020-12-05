# Mind Map

A research tool to provide users with high-quality documents for specific topics to help them track and discover relevant blogs, journal articles, and tools.

Our system gathers useful documents for researchers from various sources such as `MediaWiki Action API`, `News API (a replacement for Google News API)`, `Google Scholar API (Google Search Engine API)`, `GitHub API`...

## Project Context

The problem our project aims to solve is to keep users sain with the ever-increasing number of research points (documents) available online about specific topics. Our project allows users to subscribe to topics to discover relevant documents. Research documents are linked to each other by a specific topic(s).

The documents that our system suggests for the users are sent as suggestions to their local inbox. After a suggestion is sent to a user's inbox, they decide if the suggestion is a document they would like to keep or discard. Once their decision is made, the kept suggestions are moved to their favourites folder (? not sure what the best term for this is) and their map grows (? also not sure about this term).

## Goals

### Short-term

- Add more data sources
- Allow users to create inboxes
- Allow users to save and delete suggestions

### Long-term

The main long term goal of our project is to implement a more efficient and accuraate way to suggest documents to the users.

## Entities

These are some of the entities in our project. To see more details about the database, see the database section below.

#### Inbox

The place where all the suggestions are given to a user. I guess you can think of this as sort of an RSS feed or your email inbox.

| id  | name      | description      | url  | created_at   | updated_at   |
| --- | --------- | ---------------- | ---- | ------------ | ------------ |
| 1   | some name | some description | 1234 | created_time | updated_time |

#### Suggestion

A document that has been suggested to a user by the system.

| id  | name      | description      | source | created_at   | updated_at   |
| --- | --------- | ---------------- | ------ | ------------ | ------------ |
| 1   | some name | some description | github | created_time | updated_time |

#### Topic

A topic that can be linked to a collection of documents.

#### Document

An article, blog, or tool saved by a user.

## Geting Started

- Installation
  - `$ rbenv local 2.7.1`
  - `$ bundle install`
- API Authentication
  - Put your GITHUB_TOKEN into `config/secrets.yml`
- Generate testfile (`spec/fixtures/github_results.yml`)
  - `$ bundle exec ruby spec/fixtures/document_info.rb`
- Test the Functions & the Code Quality (based on RakeFile)
  - `$ rake spec`
  - `$ rake quality:all`

## Database

We use SQLite as our database for both development and test environments. On the production environment, we use Postgres.

- Test the getting data from github api and write to db
- `$ rake db:gwdbint`

### Entity-relationship Diagram

![](entity-relationship.png)
