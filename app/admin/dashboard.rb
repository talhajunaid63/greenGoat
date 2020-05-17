ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Latest 5 Projects" do
          Project.includes(:tasks).contract_projects.last(5).each do |project|
            panel "Project name: #{project.name}" do
              head 'Project tasks'
              hr
              ul do
                project.first_three_hot_tasks.each do |task|
                  li link_to task.title, admin_task_path(task)
                end
                br
                li link_to 'More', admin_project_path(project)
              end
            end
            hr
          end
        end
      end

      column do
        if current_admin_user
          panel "Upcoming Visits" do
            table do
              thead do
                tr do
                  th 'Buyer Name'
                  th 'Visit Detail'
                  th 'Item Status'
                end
              end

              tbody do
                ItemVisit.due.each do |item_visit|
                  tr do
                    td item_visit.user
                    td link_to "Visit Detail", admin_item_visit_path(item_visit)
                    td link_to 'Change item status', new_admin_item_product_status_path(item_id: item_visit.product.id, product_id: item_visit.product.id)
                  end
                end
              end
            end
          end
        else
          panel "Info" do
            para "Welcome Back."
          end
        end
      end
    end
  end # content
end
