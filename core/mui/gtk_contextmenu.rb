
module Gtk
  class ContextMenu
    def initialize(*context)
      @contextmenu = context end

    def registmenu(label, condition=ret_nth(), &callback)
      @contextmenu = @contextmenu.push([label, condition, callback]) end

    def registline
      if block_given?
        registmenu(nil, lambda{ |*a| yield *a }){ |a,b| }
      else
        registmenu(nil){ |a,b| } end end

    def popup(widget, optional=nil)
      Lock.synchronize{
        menu = Gtk::Menu.new
        @contextmenu.each{ |param|
          label, cond, proc = param
          if cond.call(optional, widget)
            if label
              item = Gtk::MenuItem.new(if defined? label.call then label.call(optional, widget) else label end)
              item.signal_connect('activate') { |w| proc.call(optional, widget); false } if proc
              menu.append(item)
            else
              menu.append(Gtk::MenuItem.new) end end }
        menu.attach_to_widget(widget) {|attach_widgt, mnu| notice "detached" }
        menu.show_all.popup(nil, nil, 0, 0) } end end end
