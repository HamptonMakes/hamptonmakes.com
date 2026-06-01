# Generates 1200x630 social-share cards per blog article so that LinkedIn,
# Twitter, Mastodon, etc. show the article title + description on the image
# itself (LinkedIn's large-image card layout doesn't render og:description
# below the title, so we bake the description into the image).
#
# Reads frontmatter from source/blog/*.html.md and writes
# source/images/social/<slug>.png. Skips up-to-date files.
#
# Called from config.rb's `ready` block so it runs before every build
# (and dev-server start). Also exposed as `rake social_cards`.

require 'yaml'
require 'fileutils'
require 'shellwords'

module SocialCards
  SOURCE_DIR  = File.expand_path('../source/blog',          __dir__)
  OUT_DIR     = File.expand_path('../source/images/social', __dir__)
  FONT_BOLD   = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
  FONT_REG    = '/System/Library/Fonts/Supplemental/Arial.ttf'
  FONT_BRAND  = '/Users/hampton/dev/hamptonmakes.com/source/fonts/AloneEdition.otf'
  W, H        = 1200, 630
  COLOR_INK   = '#1a1410'
  GRADIENT    = "gradient:'#ff8fb1-#8dd5f0'"

  module_function

  def generate_all
    FileUtils.mkdir_p(OUT_DIR)
    Dir.glob(File.join(SOURCE_DIR, '*.html.md')).each { |p| generate_for(p) }
  end

  def generate_for(article_path)
    meta = extract_frontmatter(article_path) or return
    title = meta['title'].to_s
    desc  = meta['description'].to_s
    slug  = File.basename(article_path, '.html.md').sub(/\A\d{4}-\d{2}-\d{2}-/, '')
    out   = File.join(OUT_DIR, "#{slug}.png")

    # Skip if up-to-date (regenerate when source or this script is newer)
    src_mtime = [File.mtime(article_path), File.mtime(__FILE__)].max
    return if File.exist?(out) && File.mtime(out) >= src_mtime

    render(title: title, description: desc, out: out)
    puts "[social_cards] generated #{out}"
  end

  # ── internals ──────────────────────────────────────────────────────────

  def extract_frontmatter(path)
    raw = File.read(path)
    return nil unless raw =~ /\A---\s*\n(.*?)\n---\s*\n/m
    YAML.safe_load($1, permitted_classes: [Date])
  end

  # Soft word-wrap to N chars/line, preserving word boundaries.
  def wrap(text, width)
    text.to_s.split(/\s+/).each_with_object([]) do |word, lines|
      if lines.empty? || (lines.last.length + word.length + 1) > width
        lines << word.dup
      else
        lines.last << ' ' << word
      end
    end.join("\n")
  end

  def render(title:, description:, out:)
    # Build args carefully (no shell interpolation surprises).
    args = [
      'magick',
      '-size', "#{W}x#{H}",
      'gradient:#ff8fb1-#8dd5f0',
      '-define', 'gradient:direction=East',
      # Title: bold, large, top-left
      '-font',      FONT_BOLD,
      '-pointsize', '70',
      '-fill',      COLOR_INK,
      '-gravity',   'NorthWest',
      '-annotate',  '+70+90',  wrap(title, 22),
      # Description: regular, medium
      '-font',      FONT_REG,
      '-pointsize', '32',
      '-interline-spacing', '6',
      '-annotate',  '+70+300', wrap(description, 50),
      # Brand line bottom-left, using site brand font if available
      '-font',      File.exist?(FONT_BRAND) ? FONT_BRAND : FONT_BOLD,
      '-pointsize', '40',
      '-annotate',  '+70+540', '@HamptonMakes',
      out
    ]
    ok = system(*args)
    raise "ImageMagick failed for #{out}" unless ok
  end
end

# Allow running directly: `ruby lib/social_cards.rb`
SocialCards.generate_all if __FILE__ == $PROGRAM_NAME
