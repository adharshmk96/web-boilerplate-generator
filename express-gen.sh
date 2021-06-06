#!/bin/bash

FOLDER_NAME=$1

usage() {
  echo "Usage: $0 Folder Name"
  exit 1
}

if [ -z $FOLDER_NAME ]
then
  echo "Error: missing parameters."
  usage
fi

echo "Initializing git & npm"

git init "$FOLDER_NAME" > /dev/null 2>&1

cd "$FOLDER_NAME"

cat <<EOT >> package.json
{ 
  "name": "$FOLDER_NAME",
  "version": "1.0.0",
  "description": "",
  "main": "build/index.js",
  "scripts": {
  	"dev": "ts-node-dev ./src/index.ts",
  	"build": "tsc",
  	"start": "tsc & node ."
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.17.1",
    "express-async-errors": "^3.1.1",
    "helmet": "^4.6.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.10",
    "@types/express": "^4.17.12",
    "@types/morgan": "^1.9.2",
    "@types/node": "^15.12.1",
    "jest": "^27.0.4",
    "nodemon": "^2.0.7",
    "ts-node-dev": "^1.1.6",
    "typescript": "^4.3.2"
  }
}
EOT

echo "Installing dependancies"

yarn install > /dev/null 2>&1

echo "Creating folder structure"

mkdir -p src src/config src/routes src/lib/middleware src/lib/errors

cat <<EOT >> ./src/index.ts
import { config } from './config';
import { app } from './app';

// Constants
const PORT = config.port;
const HOST = config.host;


app.listen(PORT, HOST, () => {
    console.log(`Running on http://${HOST}:${PORT}`);
});
EOT

cat <<EOT >> ./src/config/index.ts
const config = {
    host : "0.0.0.0",
    port : 3000,
}

export { config }
EOT

cat <<EOT >> ./src/routes/index.ts
import express from 'express';
import { userRouter } from './user';
const router = express.Router();

router.use("/", () => {
    res.status(200).json({
        status: "OK?"
    })
})

export { router as rootRouter };
EOT

cat <<EOT >> ./src/app.ts 
import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import { NotFoundError } from './lib/errors/notFound';
import { errorHandler } from './lib/middleware/errorHandler';
import { rootRouter } from './routes';

require('express-async-errors');

// Initialize express app
const app = express()


// Middlewares
const cors_middleware = cors();
const helmet_middleware = helmet();
const logger_middleware = morgan('combined')

app.use(cors_middleware);
app.use(helmet_middleware);
app.use(logger_middleware);

// Router
app.use(rootRouter)

// Default Route handling
app.use('*', async (req, res) => {
    throw new NotFoundError();
});

app.use(errorHandler)

export { app };
EOT

cat <<EOT >> ./src/lib/errors/http-error.ts
export abstract class HttpError extends Error {
	abstract statusCode: number;

	constructor(message: string) {
		super(message);
		Object.setPrototypeOf(this, HttpError.prototype);
	}

	abstract serializeErrors(): { message: string; field?: string }[];
}
EOT

cat <<EOT >> ./src/lib/errors/notFound.ts 
import { HttpError } from './http-error';

export class NotFoundError extends HttpError {
	statusCode = 404;

	constructor() {
		super('Route not found');
		Object.setPrototypeOf(this, NotFoundError.prototype);
	}

	serializeErrors() {
		return [{ message: 'The requested route is not Found' }];
	}
}
EOT

cat <<EOT >> ./src/lib/middleware/errorHandler.ts
import { NextFunction, Request, Response } from 'express';
import { HttpError } from '../errors/http-error';

export const errorHandler = (
    err: Error,
    req: Request,
    res: Response,
    next: NextFunction
) => {

    if(err instanceof HttpError) {
        return res.status(err.statusCode).send({
            errors: err.serializeErrors()
        })
    }

    console.error(err);

    res.status(500).send({
        errors: [{message: 'Something went wrong !'}]
    })

}
EOT
