var path = require("path");
var elmSource = __dirname + "/web/elm";
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: {
    app: "./web/static/js/app.js"
  },

  output: {
    path: path.resolve(__dirname + "/priv/static"),
    filename: "js/app.js"
  },

  module: {
    rules: [{
        test: /\.(css|scss)$/,
        use: [
          'style-loader',
          'css-loader',
        ]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/, /Stylesheets\.elm$/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            cwd: elmSource,
            verbose: true,
            warn: true,
            debug: true,
            forceWatch: true,
          }
        }
      },
      {
        test: /Stylesheets\.elm$/,
        use: [
          { loader: 'style-loader' },
          { loader: 'css-loader' },
          { 
            loader: 'elm-css-webpack-loader',
            options: {
              cwd: elmSource,
              emitWarning: true,
            },
          },
        ]
      },
    ],
  },

  plugins: [
    new CopyWebpackPlugin([
      { from: 'web/static/assets' }
    ])
  ]
};