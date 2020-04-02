
module CommandBotExtension
    def require_command_permission(command_name,requied_permissions) 
        @required_permissions ||= {}
        if requied_permissions.class != Array
            requied_permissions = [requied_permissions]
        end
        @required_permissions[command_name] = requied_permissions
    end
    def can_use?(command_name,user)
        return true unless @required_permissions.has_key?(command_name)
        return @required_permissions[command_name].all? {|perm|  user.permission?(perm) }
    end
    def get_command_permission(command_name)
        @required_permissions ||= {}
        @required_permissions[command_name]
    end
end
