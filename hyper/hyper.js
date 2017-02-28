module.exports = {
  config: {

    fontSize: 16,

    fontFamily: '"Liberation Mono", Menlo, "DejaVu Sans Mono", Consolas, "Lucida Console", monospace',

    cursorColor: 'rgba(255,255,0,1.0)',

    cursorShape: 'BLOCK',

    foregroundColor: '#fff',

    backgroundColor: '#000',

    borderColor: '#333',

    css: '.nav_n2c { font-family: "Liberation Mono"; font-weight: bold; } .tab_icon { display: none; } .tab_tab {border-color: #333 !important;} ',

    termCSS: '',

    showHamburgerMenu: '',

    showWindowControls: false,

    padding: '2px 10px',

    colors: {
      black: '#000000',
      red: '#ff0000',
      green: '#33ff00',
      yellow: '#ffff00',
      blue: '#0066ff',
      magenta: '#cc00ff',
      cyan: '#00ffff',
      white: '#d0d0d0',
      lightBlack: '#808080',
      lightRed: '#ff0000',
      lightGreen: '#33ff00',
      lightYellow: '#ffff00',
      lightBlue: '#0066ff',
      lightMagenta: '#cc00ff',
      lightCyan: '#00ffff',
      lightWhite: '#ffffff'
    },

    shell: '/usr/local/bin/fish',

    shellArgs: ['--login'],

    env: {},

    bell: 'SOUND',

    copyOnSelect: true,

    quickEdit: true,

    // bellSoundURL: 'http://example.com/bell.mp3',
    // for advanced config flags please refer to https://hyper.is/#cfg
    
    summonShortcut: 'F3',
    
    hyperTabs: {
      tabIconsColored: true,
      border: true,
      }
    
  },

  plugins: [
    'hyperclean', 
    'hypercwd', 
    'hyper-tab-icons',
    'hyperterm-summon',
    'hyperterm-alternatescroll',
    'hyperterm-tabs',
    'hyperterm-cursor'
    ],

  // in development, you can create a directory under
  // `~/.hyper_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: []
};
