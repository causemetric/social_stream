module ToolbarHelper
  # Define the toolbar content for your view. There are two typical cases, depending on the value of
  # options[:profile]
  # * If present, render the profile menu for the {SocialStream::Models::Subject subject}
  # * If blank, render the home menu
  #
  # The menu option allows overwriting a menu slot with the content of the given block
  #
  #
  # Autoexpanding a menu section on your view:
  #
  # Toolbar allows you to autoexpand certain menu section that may be of interest for your view.
  # For example, the messages menu when you are looking your inbox. This is done through :option element.
  #
  # To get it working, you should use the proper :option to be expanded, ":option => :messages" in the
  # mentioned example. This will try, automatically, to expand the section of the menu where its root
  # list link, the one expanding the section, has an id equal to "#messages_menu". If you use
  # ":options => :contacts" it will try to expand "#contacts_menu".
  #
  # For now its working with :option => :messages, :contacts or :groups
  #
  #
  # Examples:
  #
  # Render the home toolbar:
  #
  #   <% toolbar %>
  #
  # Render the profile toolbar for a user:
  #
  #   <% toolbar :profile => @user %>
  #
  # Render the home toolbar changing the messages menu option:
  #
  #   <% toolbar :option => :messages %>
  #
  # Render the profile toolbar for group changing the contacts menu option:
  #
  #   <% toolbar :profile => @group, :option => :contacts %>
  #
  def toolbar(options = {}, &block)
    if options[:option] && block_given?
      menu_options[options[:option]] = capture(&block)
    end

    content = capture do
      if options[:profile]
        render :partial => 'toolbar/profile', :locals => { :subject => options[:profile] }
      else
        render :partial => 'toolbar/home'
      end
    end

    case request.format
    when Mime::JS
      response = <<-EOJ

          $('#toolbar').html("#{ escape_javascript(content) }");
          initMenu();
          expandSubMenu('#{ options[:option] }');
          EOJ

      response.html_safe
    else
    content_for(:toolbar) do
    content
    end
    content_for(:javascript) do
    <<-EOJ
    expandSubMenu('#{ options[:option] }');
    EOJ
    end
    end
  end

  # Cache menu options for toolbar
  #
  # @api private
  def menu_options #:nodoc:
    @menu_options ||= {}
  end

  #Prints the home toolbar menu.
  def home_toolbar_menu
    default_home_toolbar_menu
  end

  #Prints the home profile menu.
  def profile_toolbar_menu(subject=current_subject)
    default_profile_toolbar_menu(subject)
  end
 

  #Renders array of navigation items with simple_navigation
  def render_items(items)
    menu = render_navigation :items => items
    return raw menu
  end
  
  
  include SocialStream::ToolbarConfig
end
