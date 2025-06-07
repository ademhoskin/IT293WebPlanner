import { ApolloServer } from 'apollo-server';
import { typeDefs, resolvers } from '../index';

describe('GraphQL Server', () => {
  let server: ApolloServer;

  beforeAll(() => {
    server = new ApolloServer({ typeDefs, resolvers });
  });

  afterAll(async () => {
    await server.stop();
  });

  it('should return courses', async () => {
    const result = await server.executeOperation({
      query: `
        query {
          courses {
            id
            name
            course_type
          }
        }
      `,
    });

    expect(result.errors).toBeUndefined();
    expect(result.data?.courses).toEqual([
      { id: 1, name: 'Intro to IT', course_type: 'gateway' }
    ]);
  });
}); 