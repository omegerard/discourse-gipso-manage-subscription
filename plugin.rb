# name: discourse-gipso-manage-subscription
# about: plugin to easily adjust user permissions for gipso project group members on the basis of whether or not membership fee is paid
# version: 0.0.1
# authors: Ludo Vangilbergen EL4A
# url: https://github.com/omegerard/discourse-gipso-manage-subscription

# In plugin.rb
after_initialize do
  # Zorg ervoor dat je de GroupsController laadt
  require_dependency "groups_controller"

  class ::GroupsController
    alias_method :update_group_original, :update

    def update
      custom_checkbox_key = 'membershipfee_paid'
      target_group_name = 'Gipsocommunity'
      # Roep de originele update-actie aan
      update_group_original

      # Zorg ervoor dat de update geslaagd is
      if response.status == 200
        # Vind de groep die is aangepast
        group = Group.find_by(id: params[:id])
        # Vind de specifieke groep waarvan leden moeten worden verwijderd
        target_group = Group.find_by(name: target_group_name)

        # Controleer de waarde van de custom checkbox
        if group && group.custom_fields["#{custom_checkbox_key}"] != true
          # Rails.logger.info  "HELABA: project #{group.name} heeft NIET betaald"


          if target_group
            # Verwijder alle leden van `group` uit `target_group`
            group.users.each do |user|
              if target_group.users.include?(user)
                # Rails.logger.info  "HELABA: ik verwijder #{user.username} uit de groep #{target_group.name}"
                target_group.remove(user) 
              end
            end
          end

        else
          # Rails.logger.info  "HELABA: project #{group.name} heeft wel degelijk betaald"

          if target_group
            # Voeg alle leden van `group` toe aan `target_group`
            group.users.each do |user|
              if !target_group.users.include?(user)
                # Rails.logger.info  "HELABA: ik voeg #{user.username} aan de groep #{target_group.name} toe"
                target_group.add(user) 
              end
            end
          end
        end
      end
    end
  end
end

