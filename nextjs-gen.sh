#!/bin/bash

FOLDER_NAME=$1;

usage() {
  echo "Usage: $0 <folder name>"
  exit 1
}

if [ -z $FOLDER_NAME ]
then
  echo "Error: missing parameters."
  usage
fi

echo "Initializing Nextjs Project."

npx create-next-app --typescript "$FOLDER_NAME" > /dev/null 2>&1

cd "$FOLDER_NAME"

git init .

echo "Managing dependancies..."

yarn > /dev/null 2>&1
yarn add --dev @types/node tailwindcss@latest postcss@latest autoprefixer@latest > /dev/null 2>&1

npx tailwindcss init -p

cat <<EOT >> ./tailwind.config.js
module.exports = {
  purge: ['./pages/**/*.{js,ts,jsx,tsx}', './components/**/*.{js,ts,jsx,tsx}'],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
EOT

echo "Managing boilerplate..."

rm -rf ./pages ./styles

mkdir pages styles context

cat <<EOT >> ./styles/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;

html {
  overflow-x: hidden;
  font-size: 62.5%;
}
body {
  font-size: 1.6rem;
}


EOT

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
					<title>Adharsh M</title>

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

echo "Setup complete, please cd $FOLDER_NAME and run yarn dev to continue."