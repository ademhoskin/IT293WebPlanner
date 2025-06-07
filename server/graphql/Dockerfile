FROM base AS backend
WORKDIR /app/backend
COPY server/graphql/package*.json ./
RUN npm install
COPY server/graphql .
EXPOSE 4000
CMD ["npx", "ts-node", "src/index.ts"] 