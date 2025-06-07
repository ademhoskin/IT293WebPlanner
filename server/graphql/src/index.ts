import { ApolloServer, gql } from 'apollo-server';

export const typeDefs = gql`
  type Course {
    id: Int!
    name: String!
    course_type: String!
    prereqs: String
    coreqs: String
  }

  type Query {
    courses: [Course!]!
  }
`;

export const resolvers = {
  Query: {
    courses: async () => {
      // Placeholder: Replace with DB call
      return [
        { id: 1, name: 'Intro to IT', course_type: 'gateway', prereqs: '[]', coreqs: '[]' }
      ];
    },
  },
};

export const server = new ApolloServer({ typeDefs, resolvers });

// Only start the server if this file is run directly
if (require.main === module) {
  server.listen({ port: 4000 }).then(({ url }) => {
    console.log(`🚀 Server ready at ${url}`);
  });
} 