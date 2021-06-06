#!/bin/bash

FOLDER_NAME=$1;

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

cat <<EOT >> tsconfig.json
{
  "compilerOptions": {
    /* Visit https://aka.ms/tsconfig.json to read more about this file */
    /* Basic Options */
    // "incremental": true,                   /* Enable incremental compilation */
    "target": "es5",                          /* Specify ECMAScript target version: 'ES3' (default), 'ES5', 'ES2015', 'ES2016', 'ES2017', 'ES2018', 'ES2019', 'ES2020', or 'ESNEXT'. */
    "module": "commonjs",                     /* Specify module code generation: 'none', 'commonjs', 'amd', 'system', 'umd', 'es2015', 'es2020', or 'ESNext'. */
    "strict": true,                           /* Enable all strict type-checking options. */
    "allowJs": true,                          /* Allow javascript files to be compiled. */
    "esModuleInterop": true,                  /* Enables emit interoperability between CommonJS and ES Modules via creation of namespace objects for all imports. Implies 'allowSyntheticDefaultImports'. */
    "skipLibCheck": true,                     /* Skip type checking of declaration files. */
    "baseUrl": "./",                          /* Base directory to resolve non-absolute module names. */
    "outDir": "./build",                      /* Redirect output structure to the directory. */
    "paths": {
      "*": [
        "node_modules/*"
      ]
    },                                        /* A series of entries which re-map imports to lookup locations relative to the 'baseUrl'. */
    "forceConsistentCasingInFileNames": true, /* Disallow inconsistently-cased references to the same file. */
    // "lib": [],                             /* Specify library files to be included in the compilation. */
    // "checkJs": true,                       /* Report errors in .js files. */
    // "jsx": "preserve",                     /* Specify JSX code generation: 'preserve', 'react-native', or 'react'. */
    // "declaration": true,                   /* Generates corresponding '.d.ts' file. */
    // "declarationMap": true,                /* Generates a sourcemap for each corresponding '.d.ts' file. */
    // "sourceMap": true,                     /* Generates corresponding '.map' file. */
    // "outFile": "./",                       /* Concatenate and emit output to single file. */
    // "rootDir": "./",                       /* Specify the root directory of input files. Use to control the output directory structure with --outDir. */
    // "composite": true,                     /* Enable project compilation */
    // "tsBuildInfoFile": "./",               /* Specify file to store incremental compilation information */
    // "removeComments": true,                /* Do not emit comments to output. */
    // "noEmit": true,                        /* Do not emit outputs. */
    // "importHelpers": true,                 /* Import emit helpers from 'tslib'. */
    // "downlevelIteration": true,            /* Provide full support for iterables in 'for-of', spread, and destructuring when targeting 'ES5' or 'ES3'. */
    // "isolatedModules": true,               /* Transpile each file as a separate module (similar to 'ts.transpileModule'). */
    /* Strict Type-Checking Options */
    // "noImplicitAny": true,                 /* Raise error on expressions and declarations with an implied 'any' type. */
    // "strictNullChecks": true,              /* Enable strict null checks. */
    // "strictFunctionTypes": true,           /* Enable strict checking of function types. */
    // "strictBindCallApply": true,           /* Enable strict 'bind', 'call', and 'apply' methods on functions. */
    // "strictPropertyInitialization": true,  /* Enable strict checking of property initialization in classes. */
    // "noImplicitThis": true,                /* Raise error on 'this' expressions with an implied 'any' type. */
    // "alwaysStrict": true,                  /* Parse in strict mode and emit "use strict" for each source file. */
    /* Additional Checks */
    // "noUnusedLocals": true,                /* Report errors on unused locals. */
    // "noUnusedParameters": true,            /* Report errors on unused parameters. */
    // "noImplicitReturns": true,             /* Report error when not all code paths in function return a value. */
    // "noFallthroughCasesInSwitch": true,    /* Report errors for fallthrough cases in switch statement. */
    // "noUncheckedIndexedAccess": true,      /* Include 'undefined' in index signature results */
    /* Module Resolution Options */
    // "moduleResolution": "node",            /* Specify module resolution strategy: 'node' (Node.js) or 'classic' (TypeScript pre-1.6). */
    // "rootDirs": [],                        /* List of root folders whose combined content represents the structure of the project at runtime. */
    // "typeRoots": [],                       /* List of folders to include type definitions from. */
    // "types": [],                           /* Type declaration files to be included in compilation. */
    // "allowSyntheticDefaultImports": true,  /* Allow default imports from modules with no default export. This does not affect code emit, just typechecking. */
    // "preserveSymlinks": true,              /* Do not resolve the real path of symlinks. */
    // "allowUmdGlobalAccess": true,          /* Allow accessing UMD globals from modules. */
    /* Source Map Options */
    // "sourceRoot": "",                      /* Specify the location where debugger should locate TypeScript files instead of source locations. */
    // "mapRoot": "",                         /* Specify the location where debugger should locate map files instead of generated locations. */
    // "inlineSourceMap": true,               /* Emit a single file with source maps instead of having a separate file. */
    // "inlineSources": true,                 /* Emit the source alongside the sourcemaps within a single file; requires '--inlineSourceMap' or '--sourceMap' to be set. */
    /* Experimental Options */
    // "experimentalDecorators": true,        /* Enables experimental support for ES7 decorators. */
    // "emitDecoratorMetadata": true,         /* Enables experimental support for emitting type metadata for decorators. */
    /* Advanced Options */
  },
  "include": [
    "src/**/*.ts",
  ],
  "exclude": [
    "node_modules"
  ]
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
    console.log(\`Running on http://\${HOST}:\${PORT}\`);
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
const router = express.Router();

router.use("/", (req, res) => {
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
