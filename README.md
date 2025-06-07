# IT293 Web Planner

A web application for GMU's IT 293 students to plan their degree path.

## Quick Start (Production)

1. Install Docker and Docker Compose
2. Clone this repository
3. Run:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```
4. Access the application at `http://localhost`

## Development Setup

1. Install dependencies:
   ```bash
   # Backend
   cd server/graphql
   npm install
   
   # Frontend
   cd client
   npm install
   ```

2. Start development environment:
   ```bash
   docker-compose up --build
   ```

3. Access:
   - Frontend: http://localhost:5173
   - GraphQL Playground: http://localhost:4000/graphql
   - Apache Proxy: http://localhost

## Project Structure

```
IT293WebPlanner/
├── client/                 # React Frontend
├── server/                 # Backend Services
│   ├── graphql/           # GraphQL API
│   ├── db/                # Database Layer
│   └── apache/            # Apache Reverse Proxy
├── docker-compose.yml     # Development setup
└── docker-compose.prod.yml # Production setup
```

## Environment Variables

### Production
- `MYSQL_ROOT_PASSWORD`: MySQL root password
- `MYSQL_DATABASE`: Database name
- `NODE_ENV`: Set to 'production'

### Development
- See `.env.example` files in each service directory

## Database

The application uses MySQL with Prisma ORM. To initialize the database:

```bash
cd server/db
npx prisma generate
npx prisma migrate dev
```

## Testing

```bash
# Backend tests
cd server/graphql
npm test

# Frontend tests
cd client
npm test
```

## Deployment

1. Build production images:
   ```bash
   docker-compose -f docker-compose.prod.yml build
   ```

2. Start services:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

3. Monitor logs:
   ```bash
   docker-compose -f docker-compose.prod.yml logs -f
   ```

## Support

For issues or questions, please contact [Your Contact Info]
