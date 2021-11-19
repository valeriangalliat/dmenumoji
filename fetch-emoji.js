const emojiIndex = require('unicode-emoji-json')
const keywordsIndex = require('./emojilib/dist/emoji-en')

for (const [symbol, emoji] of Object.entries(emojiIndex)) {
  const ignore = [emoji.name, emoji.slug]
  const keywords = (keywordsIndex[symbol] || []).filter(k => !ignore.includes(k))
  const keywordsText = keywords.length === 0 ? '' : ` (${keywords.join(', ')})`
  console.log(`${symbol} ${emoji.name}${keywordsText}`)
}
