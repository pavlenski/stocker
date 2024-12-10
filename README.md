# StockerApi

### starting the server

make the run file in the project directory by typing in your terminal: `chmod +x run`

to initialize and build the project, run: `./run init`
  * firstly, this will build the project
  * secondly, it will run the server on [`localhost:4000`](http://localhost:4000)
  * thirdly, a postgres instance will start which the server will be connected to
  * also, adminer will be booted on [`localhost:8090`](http://localhost:8090)
    * password: `postgres`
    * username: `postgres`
    * server: `postgres`
    * database: `stocker_api_dev`
   
### reseting the database

if needed, run `./run reset` to drop, create, migrate and reseed the database as a clean slate

### testing

for now, the container has to be running in order to run tests (either with `docker compose up` or `./run init`) \
to run the tests, run `./run test`

unfortunately, after running the tests & closing the container (`docker compose down`), \
the database has to be reset with `./run reset` \
(i messed up the sandbox environment for integration testing with postgres)

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
