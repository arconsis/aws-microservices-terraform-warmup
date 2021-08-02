const logging = require('./common/logging');
const validations = require('./presentation/middleware/validations');
const databaseFactory = require('./data/infrastructure/database');
const tokenRepositoryFactory = require('./data/repositories/token/tokenRepository');
const usersRepositoryFactory = require('./data/repositories/users/usersRepository');
const authServiceFactory = require('./domain/auth/service');
const {
  databaseUri,
} = require('./common/configuration');

const database = databaseFactory.init(databaseUri)
const tokenRepository = tokenRepositoryFactory.init();
const usersRepository = usersRepositoryFactory.init({
  dataStores: database.dataStores,
});
const authService = authServiceFactory.init({
  tokenRepository,
  usersRepository,
});

exports.handler = async function loginHandler(event, context) {
  try {
    logging.log('Enter login handler');
    await database.authenticate();
    validations.assertLoginEvent(event);
    const token = await authService.login({
      email: event.email,
      password: event.password,
    });
    const res = {
      statusCode: 200,
      body: {
        token,
      },
    };
    context.succeed(res);
  } catch (error) {
    const errMsg = error && error.message
      ? error.message
      : 'Error on login process';
    context.fail(errMsg);
  }
};
