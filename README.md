# Build a Complete Project Management Dashboard

[![Tutorial Video](https://img.youtube.com/vi/KAV8vo7hGAo/0.jpg)](https://www.youtube.com/watch?v=KAV8vo7hGAo)

This repository hosts a full‑stack project management dashboard.  
The frontend has been rebuilt with **Flutter** while the backend remains the original **Node.js/Express + Prisma** stack highlighted in the tutorial linked above.

## Join Our Community

For discussion and support for this specific app, join our [Discord community](https://discord.com/channels/1070200085440376872/1082900634442940416/threads/1282730219488280576).

## Technology Stack

- **Frontend**: Flutter (Material 3, Riverpod, GoRouter, Dio, fl_chart)
- **Backend**: Node.js with Express, Prisma (PostgreSQL ORM)
- **Database**: PostgreSQL, managed with PgAdmin
- **Cloud**: AWS components (EC2, RDS, API Gateway, Amplify, S3, Lambda, Cognito) per the tutorial

## Getting Started

### Prerequisites

Ensure you have these tools installed:

- Git
- Flutter SDK (which bundles Dart) – [installation guide](https://docs.flutter.dev/get-started/install)
- Node.js 18+ and npm
- PostgreSQL + PgAdmin (for running the Prisma database)

### Installation Steps

1. **Clone and enter the repo**
   ```bash
   git clone <repo-url>
   cd project-management
   ```

2. **Install server dependencies**
   ```bash
   cd server
   npm install
   ```

3. **Install Flutter dependencies**
   ```bash
   cd ../client
   flutter pub get
   cp .env.example .env   # adjust API_BASE_URL / DEFAULT_USER_ID as desired
   ```

4. **Prepare the database (from `/server`)**
   ```bash
   npx prisma generate
   npx prisma migrate dev --name init
   npm run seed
   ```

5. **Environment variables**
   - `server/.env` – contains `PORT`, `DATABASE_URL`, and any AWS credentials
   - `client/.env` – contains `API_BASE_URL` (defaults to `http://localhost:3000`) and optional `DEFAULT_USER_ID`

6. **Run the stack**
   - API: `cd server && npm run dev`
   - Flutter web: `cd client && flutter run -d chrome`
     (or choose another device ID such as `-d linux`/`macos`/`windows` depending on your tooling)

## Additional Resources

- Server, Prisma schema, and seed data live under `/server`
- Flutter application lives under `/client`
- [Database seed files](https://github.com/ed-roh/project-management/tree/master/server/prisma/seedData)
- [Image files](https://github.com/ed-roh/project-management/tree/master/client/public)
- [globals.css file (to copy for Gantt charts)](https://github.com/ed-roh/project-management/blob/master/client/src/app/globals.css)
- [AWS EC2 Instruction file](https://github.com/ed-roh/project-management/blob/master/server/aws-ec2-instructions.md)

### Diagrams and Models

- [Data model diagram](https://lucid.app/lucidchart/877dec2c-db89-4f7b-9ce0-80ce88b6ee37/edit)
- [AWS architecture diagram](https://lucid.app/lucidchart/62c20695-d936-4ee7-9a53-ceef7aef8127/edit)
- [AWS Cognito flow diagram](https://lucid.app/lucidchart/9e17e28e-6fe5-41df-b04b-b378fa21eb8f/edit)

### Database Management Commands

- Command for resetting ID in database:
  ```sql
  SELECT setval(pg_get_serial_sequence('"[DATA_MODEL_NAME_HERE]"', 'id'), coalesce(max(id)+1, 1), false) FROM "[DATA_MODEL_NAME_HERE]";
  ```
