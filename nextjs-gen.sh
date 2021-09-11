#!/bin/bash

FOLDER_NAME=$1;

usage() {
  echo "Usage: $0 <folder name>"
  exit 1
}

initialize_git() {

git init "$FOLDER_NAME"
cd "$FOLDER_NAME"

}

generate_gitignore() {
cat <<EOT >> .gitignore
# See https://help.github.com/articles/ignoring-files/ for more about ignoring files.

# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env.local
.env.development.local
.env.test.local
.env.production.local

# vercel
.vercel
EOT
}

initialize_nextjs() {

echo "Initializing Nextjs Project."

npm i -g create-next-app

npx create-next-app --typescript .

# cd "$FOLDER_NAME"

}

install_deps_locally() {

echo "Managing dependancies..."

yarn > /dev/null 2>&1

# Installing UI Libararies
yarn add --dev @types/node tailwindcss@latest postcss@latest autoprefixer@latest @headlessui/react > /dev/null 2>&1

npx tailwindcss init -p

# Installing Testing Libraries
# yarn add --dev jest ts-jest @types/jest @testing-library/react @testing-library/dom @testing-library/user-event @testing-library/jest-dom  > /dev/null 2>&1

# yarn ts-jest config:init

}

pages_boilerplate() {
# Configuring pages

cat <<EOT >> ./pages/_app.tsx
import { AppProps } from "next/dist/next-server/lib/router/router";
import Head from "next/head";
import ContextProvider from "../context";
import "../styles/index.css";

// This default export is required in a new \`pages/_app.tsx\` file.
export default function MyApp({ Component, pageProps }: AppProps) {
	return (
		<>
			<ContextProvider pageProps={pageProps}>
				<Head>
					<title>$FOLDER_NAME</title>

					<meta
						name="viewport"
						content="width=device-width, initial-scale=1"
					/>
					<meta charSet="utf-8" />

					<link rel="icon" href="/favicon.ico" />
				</Head>

				<Component {...pageProps} />
			</ContextProvider>
		</>
	);
}
EOT

cat <<EOT >> ./pages/_document.tsx
import Document, { DocumentContext, Head, Html, Main, NextScript } from 'next/document'

class MyDocument extends Document {
    static async getInitialProps(ctx: DocumentContext) {
        const initialProps = await Document.getInitialProps(ctx)
        return { ...initialProps }
    }

    render() {
        return (
            <Html>
                <Head />
                <body>
                    <Main />
                    <NextScript />
                </body>
            </Html>
        )
    }
}

export default MyDocument
EOT

cat <<EOT >> ./pages/index.tsx
import { NextPage } from 'next';

const Home: NextPage<{}> = () => {
  return <>
  <div className={"h-screen grid place-items-center"}>
    <h1>Hello World !</h1>
  </div>
  </>
}

export default Home
EOT
}

context_boilerplate() {

cat <<EOT >> ./context/index.tsx
import { FC } from "react";

type TContextProvider = {
    pageProps: any;
};

const ContextProvider: FC<TContextProvider> = ({ pageProps, children }) => (
    <>
        { children}
    </>
);

export default ContextProvider;
EOT

}

style_boilerplate() {
# Tailwind setup

cat <<EOT >> ./tailwind.config.js
module.exports = {
	purge: [
		"./pages/**/*.{js,ts,jsx,tsx}",
		"./components/**/*.{js,ts,jsx,tsx}",
	],
	darkMode: false, // or 'media' or 'class'
	theme: {
		extend: {},
	},
	variants: {
		extend: {},
	},
	plugins: [],
};
EOT

cat <<EOT >> ./styles/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;
EOT
}


config_boilerplate() {

mkdir jest

cat <<EOT >> ./jest/jest.setup.ts
import '@testing-library/jest-dom'
EOT    

cat <<EOT >> ./jest.config.js
/** @type {import('ts-jest/dist/types').InitialOptionsTsJest} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  globals: {
    'ts-jest': {
      tsconfig: 'tsconfig.jest.json',
    },
  },
  setupFilesAfterEnv: ['./jest/jest.setup.ts']
};
EOT


cat <<EOT >> tsconfig.jest.json
{
    "extends": "./tsconfig.json",
    "compilerOptions": {
        "jsx": "react-jsx"
    }
}
EOT

}

generate_boilerplate() {

echo "Managing boilerplate..."

rm -rf ./pages ./styles

mkdir pages styles context components

pages_boilerplate

context_boilerplate

style_boilerplate

}



if [ -z $FOLDER_NAME ]
then
  echo "Error: missing parameters."
  usage
fi

initialize_git

generate_gitignore

initialize_nextjs

generate_boilerplate

install_deps_locally

# config_boilerplate


echo "Setup complete, please cd $FOLDER_NAME and run yarn dev to continue."
