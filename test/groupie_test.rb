require File.join(File.dirname(__FILE__), 'test_helper')

Testy.testing 'Groupie' do
  test 'classification is certain' do |t|
    g = Groupie.new
    g[:spam].add %w[viagra]
    g[:ham].add %w[flowers]
    classification = g.classify 'viagra'
    t.check 'viagra is',
      :expect => {:spam => 1.0, :ham => 0.0},
      :actual => classification
  end

  test 'classification is split between two groups' do |t|
    g = Groupie.new
    g[:spam].add %w[buy viagra now]
    g[:ham].add %w[buy flowers for your mom]
    classification = g.classify 'buy'
    t.check 'buy is classified as',
      :expect => {:spam => 0.5, :ham => 0.5},
      :actual => classification
  end

  test 'classification is weighed more heavy in one group' do |t|
    g = Groupie.new
    g[:spam].add %w[buy viagra now]
    g[:spam].add %w[buy cialis now]
    g[:ham].add %w[buy flowers for your mom]
    t.check 'buy is classified as',
      :expect => {:spam => 2 / 3.0, :ham => 1 / 3.0},
      :actual => g.classify('buy')
  end

  test 'classification works fine with more than two groups' do |t|
    g = Groupie.new
    g[:weight].add 'pound'
    g[:currency].add 'pound'
    g[:phone_key].add 'pound'
    t.check 'pound is classified as',
      :expect => {:weight => 1/3.0, :currency => 1/3.0, :phone_key => 1/3.0},
      :actual => g.classify('pound')
  end

  test 'tokenized emails' do |t|
    email = <<-EMAIL
I noticed your flirt
If you cannot see the pictures and links below, please click here to view them.
PHARMACY CLUB | UNSUBSCRIBE | YOUR PRIVACY RIGHTS
Copyright 2009 Zjfqq, all rights reserved
Customer Service Dept., 87 Hizq Iveox Street, Isahaylo, VS 25270
    EMAIL
    email2 = <<-EMAIL
Re: Your subscribe #976589
Tell a friend Â· Download latest version	See this email as a webpage
Hello!
Shipped Privately And Discreetly To Your Door!
We want to put a great big grin on your face in 2009. You'll be to rejoice all year.
Unsubscribe Â· Lost Password Â· Account Settings Â· Help Â· Terms of Service Â· Privacy
Ottho Heldringstraat 2, 31719 AZ Amsterdam, The Netherlands
    EMAIL
    email3 = <<-EMAIL
Re: [ubuntu-art] [Breathe] Network Manager-icons
Am Sonntag, den 31.05.2009, 17:53 +0200 schrieb Steve Dodier:
> Hello,
>
> I think the notify-osd icons have a completely different style, which
> is looking great within the notification bubbles, but i doubt it'd
> look great to have the notify-osd wifi icons in the panel. I think the
> drawing of the notification- wifi icons should be done afterwards, and
> if they should be based on those of the icon set, they could be made
> smoother, and possibly desaturated for some of them, to avoid drawing
> too much attention from the user when popping up.
>
> Cordially, SD.
    EMAIL
    g = Groupie.new
    g[:spam].add email.tokenize
    g[:spam].add email2.tokenize
    g[:ham].add email3.tokenize
    t.check 'classification of "a"',
      :expect => {:spam => 0.75, :ham => 0.25},
      :actual => g.classify('a')
    t.check 'classification of "the"',
      :expect => {:spam => 0.2, :ham => 0.8},
      :actual => g.classify('the')
    t.check 'classification of "great"',
      :expect => {:spam => 1/3.0, :ham => 2/3.0},
      :actual => g.classify('great')
    t.check 'classification of "to"',
      :expect => {:spam => 2/3.0, :ham => 1/3.0},
      :actual => g.classify('to')
  end

  test 'tokenized html emails' do |t|
    g = Groupie.new
    spam_tokens = File.read(File.join(File.dirname(__FILE__),
      %w[fixtures spam spam.la-44118014.txt])).tokenize
    ham_tokens = File.read(File.join(File.dirname(__FILE__),
      %w[fixtures ham spam.la-44116217.txt])).tokenize
    g[:spam].add spam_tokens
    g[:ham].add ham_tokens
    classification = g.classify 'to'
    t.check 'classification of "to"',
      :expect => {:spam => 2/3.0, :ham => 1/3.0},
      :actual => classification
    t.check 'classification of spam email is spam',
      :expect => true,
      :actual => g.classify_text(spam_tokens)[:spam] > 0.99
  end

  test 'classify a text' do |t|
    g = Groupie.new
    g[:spam].add %w[buy viagra now to grow fast]
    g[:spam].add %w[buy cialis on our website]
    g[:ham].add %w[buy flowers for your mom]
    result = g.classify_text "Grow flowers to sell on our website".tokenize
    t.check 'classification of a spammy text',
      :expect => {:spam => 0.96875, :ham => 0.03125},
      :actual => result
    result2 = g.classify_text "Grow flowers to give to your mom".tokenize
    t.check 'classification of a non-spammy text',
      :expect => {:spam => 0.21875, :ham => 0.78125},
      :actual => result2
  end
end
