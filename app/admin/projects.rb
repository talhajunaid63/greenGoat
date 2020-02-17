ActiveAdmin.register Project, as: 'Project' do
  actions :all, except: [:new, :create]

  filter :user, input_html: { class: 'select2-dropdown' }, label: 'Weight by user'
  filter :pm, as: :select, collection: AdminUser.pms, input_html: { class: 'select2-dropdown' }
  filter :appraiser, as: :select, collection: AdminUser.appraisers, input_html: { class: 'select2-dropdown' }
  filter :contractor, as: :select, collection: AdminUser.contractors, input_html: { class: 'select2-dropdown' }
  filter :architect, as: :select, collection: AdminUser.architects, input_html: { class: 'select2-dropdown' }
  filter :zillow_location, input_html: { class: 'select2-dropdown' }
  filter :created_at, label: 'Weight by Year'
  filter :contract_date
  filter :visit_date
  filter :demo_date

  scope 'Projects Approaching Demo', :approaching_demo
  scope('Show All') { |scope| scope.contract_projects }

  index do
    selectable_column
    column :name
    column :type_of_project
    column :start_date
    column :year_built
    column :estimated_value
    column :estimated_time
    column :status
    column :demo_date
      column :client do |project|
        link_to project.user, admin_client_path(project.user) if project.user
      end
    if params.dig(:q, :user_id_eq) || params.dig(:q, :created_at_gteq_datetime) || params.dig(:q, :created_at_lteq_datetime)
      column :total_weight
      %w[wood glass metal stone_plastic other].each do |key|
        column "Total #{key.titleize}" do |project|
          project.sum_of_material_type(key)
        end
      end
    else
      column :'pm' do |project|
        link_to project.pm, admin_admin_user_path(project.pm) if project.pm
      end
      column :appraiser do |project|
        link_to project.appraiser, admin_admin_user_path(project.appraiser) if project.appraiser
      end
      column :contractor do |project|
        link_to project.contractor, admin_admin_user_path(project.contractor) if project.contractor
      end
      column :architect do |project|
        link_to project.architect, admin_admin_user_path(project.architect) if project.architect
      end
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :user, input_html: { disabled: true }
      f.input :pm, as: :select, collection: AdminUser.pms, input_html: { class: 'select2-dropdown' }
      f.input :appraiser, as: :select, collection: AdminUser.appraisers, input_html: { class: 'select2-dropdown' }
      f.input :contractor, as: :select, collection: AdminUser.contractors, input_html: { class: 'select2-dropdown' }
      f.input :architect, as: :select, collection: AdminUser.architects, input_html: { class: 'select2-dropdown' }
      f.input :zillow_location, input_html: { class: 'select2-dropdown' }
      f.input :contract_date, as: :date_picker
      f.input :access_info
      f.input :name, label: 'Project Name'
      f.input :type_of_project
      f.input :address
      f.input :city
      f.input :state
      f.input :zip
      f.input :start_date, as: :date_picker
      f.input :demo_date, as: :date_picker
      f.input :year_built
      f.input :val_sf
      f.input :estimated_value
      f.input :status
      f.input :picture, as: :file
      f.input :is_hot
    end
    f.inputs name: 'Tasks' do
      f.has_many :tasks, heading: false do |a|
        a.inputs do
          a.input :job_number, input_html: { value: a.object.job_number.blank? ? 'This will be created automatically' : a.object.job_number, readonly: true }
          a.input :title
          a.input :description
          a.input :estimated_time
          a.input :is_hot
          a.input :closed, label: "This task is Closed by <b>#{a.object.closed_by}</b>".html_safe, input_html: { disabled: true } if a.object.closed

          a.has_many :notes, heading: 'Notes' do |n|
            n.input :message, label: 'note', input_html: { readonly: n.object.created_by && (n.object.created_by != current_admin_user)  }
            if n.object.new_record? || (n.object.created_by == current_admin_user)
              n.input :created_by_id, input_html: { value: current_admin_user.id }, as: :hidden
              n.input :_destroy, as: :boolean, required: false, label: 'Delete note'
            end
          end
          a.input :_destroy, as: :boolean, required: false, label: 'Delete task'
        end
      end
    end

    f.inputs name: 'Group Items' do
      f.has_many :group_items, heading: false do |a|
        a.input :title
        a.input :description
        a.input :price
        a.input :product_ids, label: 'Item Ids', as: :select, collection: project.products.all.map {|u| [u.title, u.id]}, input_html: { class: 'select2-dropdown', multiple: "true" }
        a.input :sold
        a.input :project_id, :input_html => { :value => project.id }, as: :hidden
        a.input :_destroy, as: :boolean, required: false, label: 'Delete Group Item'
      end
    end
    f.submit
  end

  show do
    attributes_table do
      row :picture do |project|
        project.picture.attached? ? image_tag(project.picture, size: '80x80') : 'Picture not attached'
      end
      row :project_name do |project|
        project.name
      end
      row :pm do |project|
        link_to project.pm, admin_admin_user_path(project.pm) if project.pm
      end
      row :appraiser do |project|
        link_to project.appraiser, admin_admin_user_path(project.appraiser) if project.appraiser
      end
      row :contractor do |project|
        link_to project.contractor, admin_admin_user_path(project.contractor) if project.contractor
      end
      row :architect do |project|
        link_to project.architect, admin_admin_user_path(project.architect) if project.architect
      end
      row :zillow_location do |project|
        link_to project.zillow_location, admin_zillow_location_path(project.zillow_location) if project.zillow_location
      end
      row :contract_date
      row :type_of_project
      row :address
      row :city
      row :state
      row :zip
      row :start_date
      row :year_built
      row :val_sf
      row :estimated_value
      row :status
      row :is_hot
      row :demo_date
      panel "Tasks" do
        table_for project.tasks do
          column :job_number
          column :estimated_time
          column :start_date
          column :closed_date
          column :closed_by do |task|
            link_to task.closed_by, admin_admin_user_path(task.closed_by) if task.closed_by
          end
          column "Close Task" do |task|
            if task.closed
              'Closed'
            else
              link_to 'Close task', close_admin_task_path(task), data: { confirm: 'Are you sure, you want to close this task?' }
            end
          end
          column 'Notes' do |task|
            link_to "Notes", admin_task_path(task)
          end
        end
      end

      panel "Items" do
        table_for project.products do
          column :title
          column :link do |p| link_to "View", admin_item_path(p) end
          column "Sale" do |product|
            if product.sales.blank?
              link_to "Add Sale",  new_admin_item_sale_path(product)
            else
              link_to "View sales",  admin_item_sales_path(product)
            end
          end

          column "Change Location" do |item|
            link_to 'Change', new_admin_item_location_path(item_id: item.id)
          end
        end
      end

      panel "Group Items" do
        table_for project.group_items do
          column :title
          column :price
          column "Items" do |group_item|
            Product.where(id: group_item.product_ids).pluck(:title)
          end
          column :sold
        end
      end
    end
  end

  controller do
    def scoped_collection
      return Project.contract_projects if current_admin_user.admin?
      Project.contract_projects.method("#{current_admin_user.role}_projects}").call(current_admin_user.id)
    end
  end

  permit_params :name, :type_of_project, :address, :city, :state, :zip, :year_built, :picture,
        :user_id, :status, :tracking_id, :val_sf, :estimated_value, :start_date, :demo_date, :pm_id, :appraiser_id, :contractor_id, :architect_id,
        tasks_attributes: [:id, :estimated_time, :title, :description,
                           :is_hot, :_destroy, notes_attributes: [:id, :message, :created_by_id, :_destroy]],
        group_items_attributes: [:id, :title, :price, :description, :project_id, :sold, :_destroy, :product_ids => [] ]
end
