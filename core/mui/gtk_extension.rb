miquire :core, 'utils'

require 'gtk2'
require 'monitor'

=begin rdoc
= Gtk::Lock Ruby::Gnome2の排他制御
メインスレッド以外でロックしようとするとエラーを発生させる。
Gtkを使うところで、メインスレッドではない疑いがある箇所は必ずGtk::Lockを使う。
=end
class Gtk::Lock
  # ブロック実行前に _lock_ し、実行後に _unlock_ する。
  # ブロックの実行結果を返す。
  def self.synchronize
    begin
      lock
      yield
    ensure
      unlock
    end
  end

  # メインスレッド以外でこの関数を呼ぶと例外を発生させる。
  def self.lock
    raise 'Gtk lock can mainthread only' if Thread.main != Thread.current
  end

  def self.unlock
  end
end

class Gtk::Widget < Gtk::Object
  # ウィジェットを上寄せで配置する
  def top
    Gtk::Alignment.new(0.0, 0, 0, 0).add(self)
  end

  # ウィジェットを横方向に中央寄せで配置する
  def center
    Gtk::Alignment.new(0.5, 0, 0, 0).add(self)
  end

  # ウィジェットを左寄せで配置する
  def left
    Gtk::Alignment.new(0, 0, 0, 0).add(self)
  end

  # ウィジェットを右寄せで配置する
  def right
    Gtk::Alignment.new(1.0, 0, 0, 0).add(self)
  end

  # ウィジェットにツールチップ _text_ をつける
  def tooltip(text)
    Gtk::Tooltips.new.set_tip(self, text, '')
    self end
end

class Gtk::Container < Gtk::Widget
  # _widget_ を詰めて配置する。closeupで配置されたウィジェットは無理に親の幅に合わせられることがない。
  # pack_start(_widget_, false)と等価。
  def closeup(widget)
    self.pack_start(widget, false)
  end
end

class Gtk::TextBuffer < GLib::Object
  # _idx_ 文字目を表すイテレータと、そこから _size_ 文字後ろを表すイテレータの2要素からなる配列を返す。
  def get_range(idx, size)
    [self.get_iter_at_offset(idx), self.get_iter_at_offset(idx + size)]
  end
end

class Gtk::Clipboard
  # 文字列 _t_ をクリップボードにコピーする
  def self.copy(t)
    Gtk::Clipboard.get(Gdk::Atom.intern('CLIPBOARD', true)).text = t
  end
end

class Gtk::Dialog
  # メッセージダイアログを表示する。
  def self.alert(message)
    Gtk::Lock.synchronize{
      dialog = Gtk::MessageDialog.new(nil,
                                      Gtk::Dialog::DESTROY_WITH_PARENT,
                                      Gtk::MessageDialog::QUESTION,
                                      Gtk::MessageDialog::BUTTONS_CLOSE,
                                      message)
      dialog.run
      dialog.destroy
    }
  end

  # Yes,Noの二択の質問を表示する。
  # OKボタンが押されたらtrue、それ以外が押されたらfalseを返す
  def self.confirm(message)
    Gtk::Lock.synchronize{
      dialog = Gtk::MessageDialog.new(nil,
                                      Gtk::Dialog::DESTROY_WITH_PARENT,
                                      Gtk::MessageDialog::QUESTION,
                                      Gtk::MessageDialog::BUTTONS_YES_NO,
                                      message)
      res = dialog.run
      dialog.destroy
      res == Gtk::Dialog::RESPONSE_YES
    }
  end
end

# module GLib::SignalAdditional

#   def additional_signals
#     if not(@additional_signals) then
#       @additional_signals = Hash.new
#     end
#     @additional_signals
#   end

#   def signal_add(signal_name)
#     if additional_signals.has_key?(signal_name.to_sym) then
#       raise ArgumentError.new('already exist signal '+signal_name)
#     end
#     additional_signals[signal_name.to_sym] = Array.new
#     self
#   end

#   def signal_connect(detailed_signal, *other_args)
#     if not(additional_signals.has_key?(detailed_signal.to_sym)) then
#       return super(detailed_signal, *other_args)
#     end
#     additional_signals[detailed_signal.to_sym] << lambda{ |*args| yield(*args.concat(other_args)) }
#     true # handler not support
#   end

#   def signal_emit(detailed_signal, *args)
#     if not(additional_signals.has_key?(detailed_signal.to_sym)) then
#       Lock.synchronize{ super(detailed_signal, *args) }
#     else
#       additional_signals[detailed_signal.to_sym].each{ |signal|
#         if signal.call(*args) then
#           break
#         end
#       }
#     end
#   end

# end

# _url_ を設定されているブラウザで開く
def Gtk::openurl(url)
  if UserConfig[:url_open_command]
    system("#{UserConfig[:url_open_command]} #{url} &")
  elsif(defined? Win32API) then
    shellExecuteA = Win32API.new('shell32.dll','ShellExecuteA',%w(p p p p p i),'i')
    shellExecuteA.call(0, 'open', url, 0, 0, 1)
  else
    if command_exist?('xdg-open')
      command = 'xdg-open'
    else
      command = '/etc/alternatives/x-www-browser' end
    system("#{command} #{url} &") || system("firefox #{url} &") end end
