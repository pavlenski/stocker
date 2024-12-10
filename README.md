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
   
### fetching dependencies

if for some reason the deps weren't fetched upon `./run init`, you can run `./run deps.get`
   
### reseting the database

if needed, run `./run reset` to drop, create, migrate and reseed the database as a clean slate

### testing

for now, the container has to be running in order to run tests (either with `docker compose up` or `./run init`) \
to run the tests, run `./run test`

unfortunately, after running the tests & closing the container (`docker compose down`), \
the database has to be reset with `./run reset` \
(i messed up the sandbox environment for integration testing with postgres)

## api

### stocks

**GET** ```http://localhost:4000/api/stocks``` \
**POST** ```http://localhost:4000/api/stocks``` 

payload:

```
{
	"stock": {
		"name": "KupujemProdajem",
		"ticker": "KPKP",
		"created_at": "1999-07-15"
	}
}
```

**PATCH** ```http://localhost:4000/api/stocks/:stock_id```

payload:

```
{
	"stock": {
		"name": "ProdajemKupujem",
		"ticker": "PKPK",
		"created_at": "2002-07-15"
	}
}
```

**DEL** ```http://localhost:4000/api/stocks/:stock_id```

### csv file (zipped) importing

**POST** ```http://localhost:4000/api/stocks/:stock_id/import/csv/zipped```

payload - form data (multipart) \

**THE FILES SENT MUST BE ZIPPED**

<img width="578" alt="image" src="https://github.com/user-attachments/assets/42156460-3bef-497b-a15d-741bcce9cd58">

### trade options

**GET** ```http://localhost:4000/api/stocks/:ticker/trade-options```

query params

  * date_from
  * date_to

example url: ```http://localhost:4000/api/stocks/aapl/trade-options?date_from=1980-12-12&date_to=1980-12-17```

the seeded tickers for example are AAPL (Apple), GOOG (Google) etc.

example response:

```
{
	"params": {
		"date_from": "1980-12-12",
		"date_to": "1980-12-17",
		"ticker": "aapl"
	},
	"current_dates": {
		"date_from": "1980-12-12",
		"date_to": "1980-12-17",
		"multi_trade": "0.002790",
		"single_trade": {
			"buy_date": "1980-12-16",
			"buy_date_close": "0.112723",
			"max_profit": "0.002790",
			"sell_date": "1980-12-17",
			"sell_date_close": "0.115513"
		}
	},
	"former_dates": "No data for former range",
	"latter_dates": {
		"date_from": "1980-12-18",
		"date_to": "1980-12-23",
		"multi_trade": "0.036273",
		"single_trade": {
			"buy_date": "1980-12-18",
			"buy_date_close": "0.118862",
			"max_profit": "0.018973",
			"sell_date": "1980-12-23",
			"sell_date_close": "0.137835"
		}
	},
	"stock": {
		"id": "eb67d24c-1aff-46be-b3b3-db81b2f23847",
		"name": "Apple",
		"ticker": "AAPL",
		"inserted_at": "2024-12-10T18:34:44",
		"created_at": "1980-12-12",
		"updated_at": "2024-12-10T18:34:44"
	}
}
```

