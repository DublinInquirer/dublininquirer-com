export const styles = {
  base: {
    color: '#070707',
    fontWeight: '400',
    fontFamily: '"Zirkon", sans-serif',
    fontSize: '17.5px',
    fontSmoothing: 'optimizeLegibility',
    ':focus': {
      color: '#000'
    },
    '::placeholder': {
      color: '#999'
    },
    ':focus::placeholder': {
      color: '#DDD'
    }
  },
  invalid: {
    color: '#FC4604',
    ':focus': {
      color: '#070707'
    },
    '::placeholder': {
      color: '#FED1C0'
    }
  }
};

export const classes = {
  focus: '-focus',
  empty: '-empty',
  invalid: '-invalid'
};

export const fonts = [
  {
    family: 'Zirkon',
    src: 'url(https://d1trxack2ykyus.cloudfront.net/fonts/GT-Zirkon-Light.woff2)',
    style: 'normal',
    weight: '400'
  }
]