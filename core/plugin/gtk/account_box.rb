# -*- coding: utf-8 -*-

require "gtk2"

class Gtk::AccountBox < Gtk::EventBox
  UserConfig[:gtk_accountbox_geometry] ||= 32

  def initialize
    Plugin[:gtk].on_primary_service_changed(&method(:change_user))
    super
    Plugin[:gtk].on_service_registered do |service|
      refresh end
    Plugin[:gtk].on_service_destroyed do |service|
      refresh end
    ssc(:button_press_event) do |this,event|
      open_menu event if 3 >= event.button
      false end
    ssc_atonce(:realize) do
      change_user Service.primary end
  end
  
  def refresh
    if 1 < Service.to_a.size
      if not @face
        @face = Gtk::Image.new(Gdk::WebImageLoader.loading_pixbuf(UserConfig[:gtk_accountbox_geometry], UserConfig[:gtk_accountbox_geometry]))
        self.add(@face).show_all end
    else
      if @face
        self.remove(@face)
        @face.destroy
        @face = nil end end
  end

  def change_user(service)
    refresh
    if @face
      user = service.user_obj
      @face.pixbuf = Gdk::WebImageLoader.pixbuf(user[:profile_image_url], UserConfig[:gtk_accountbox_geometry], UserConfig[:gtk_accountbox_geometry]){ |pixbuf|
        if user == service.user_obj
          @face.pixbuf = pixbuf end } end end

  def open_menu(event)
    menu = Gtk::Menu.new
    Service.each do |service|
      item = Gtk::ImageMenuItem.new(service.user, false)
      item.set_image Gtk::WebIcon.new(service.user_obj[:profile_image_url], UserConfig[:gtk_accountbox_geometry], UserConfig[:gtk_accountbox_geometry])
      item.ssc(:activate) { |w|
        Service.set_primary(service)
        false }
      menu.append item end
    menu.show_all.popup(nil, nil, event.button, event.time) end
end
