require File.expand_path('../spec_helper', __FILE__)

describe R18n::Translation do

  it "returns unstranslated string if translation isn't found" do
    i18n = R18n::I18n.new('en', DIR)
    expect(i18n.not.exists).to be_kind_of(R18n::Untranslated)
    expect(i18n.not.exists).not_to be_translated
    expect(i18n.not.exists | 'default').to eq('default')
    expect(i18n.not.exists.locale).to eq(R18n.locale('en'))

    expect(i18n.not.exists).to eq(i18n.not.exists)
    expect(i18n.not.exists).not_to eq(i18n.not.exists2)

    expect(i18n.in | 'default').to eq('default')

    expect(i18n.one).to be_translated
    expect(i18n.one | 'default').to eq('One')
  end

  it "returns html escaped string" do
    klass = Class.new(R18n::TranslatedString) do
      def html_safe
        '2'
      end
    end
    str = klass.new('1', nil, nil)

    expect(str).to be_html_safe
    expect(str.html_safe).to eq('2')
  end

  it "loads use hierarchical translations" do
    i18n = R18n::I18n.new(['ru', 'en'], DIR)
    expect(i18n.in.another.level).to eq('Иерархический')
    expect(i18n[:in][:another][:level]).to eq('Иерархический')
    expect(i18n['in']['another']['level']).to eq('Иерархический')
    expect(i18n.only.english).to eq('Only in English')
  end

  it "saves path for translation" do
    i18n = R18n::I18n.new('en', DIR)

    expect(i18n.in.another.level.path).to eq('in.another.level')

    expect(i18n.in.another.not.exists.path).to eq('in.another.not.exists')
    expect(i18n.in.another.not.exists.untranslated_path).to eq('not.exists')
    expect(i18n.in.another.not.exists.translated_path).to eq('in.another.')

    expect(i18n.not.untranslated_path).to eq('not')
    expect(i18n.not.translated_path).to eq('')
  end

  it "returns translation keys" do
    i18n = R18n::I18n.new('en', [DIR, TWO])
    expect(i18n.in.translation_keys).to match_array(['another', 'two'])
  end

  it "returns string with locale info" do
    i18n = R18n::I18n.new(['nolocale', 'en'], DIR)
    expect(i18n.one.locale).to eq(R18n::UnsupportedLocale.new('nolocale'))
    expect(i18n.two.locale).to eq(R18n.locale('en'))
  end

  it "filters typed data" do
    en = R18n.locale('en')
    translation = R18n::Translation.new(en, '', locale: en, translations:
      { 'count' => R18n::Typed.new('pl', { 1 => 'one', 'n' => 'many' }) })

    expect(translation.count(1)).to eq('one')
    expect(translation.count(5)).to eq('many')
  end

  it "returns hash of translations" do
    i18n = R18n::I18n.new('en', DIR)
    expect(i18n.in.to_hash).to eq({
      'another' => { 'level' => 'Hierarchical' }
    })
  end

  it "returns untranslated, when we go deeper string" do
    en = R18n.locale('en')
    translation = R18n::Translation.new(en, '',
      locale: en, translations: { 'a' => 'A' })

    expect(translation.a.no_tr).to be_kind_of(R18n::Untranslated)
    expect(translation.a.no_tr.translated_path).to   eq('a.')
    expect(translation.a.no_tr.untranslated_path).to eq('no_tr')
  end

  it "inspects translation" do
    en = R18n.locale('en')

    translation = R18n::Translation.new(en, 'a',
      locale: en, translations: { 'a' => 'A' })
    expect(translation.inspect).to eq('Translation `a` for en {"a"=>"A"}')

    translation = R18n::Translation.new(en, '',
      locale: en, translations: { 'a' => 'A' })
    expect(translation.inspect).to eq('Translation root for en {"a"=>"A"}')

    translation = R18n::Translation.new(en, '')
    expect(translation.inspect).to eq('Translation root for en {}')
  end
end
