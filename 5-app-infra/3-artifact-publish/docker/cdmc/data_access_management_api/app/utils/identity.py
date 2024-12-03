from googleapiclient.discovery import build
from urllib.parse import urlencode

MANAGER_ROLES = {"MANAGER", "OWNER"}

service = build("cloudidentity", "v1")


def get_group_parent(group_email):
    request = service.groups().lookup(groupKey_id=group_email)
    parent = request.execute()
    return parent['name']


def is_group_manager(user_email, group_email):
    parent = get_group_parent(group_email)
    response = service.groups().memberships().list(parent=parent).execute()
    for member in response.get("memberships", []):
        if member["preferredMemberKey"]["id"] == user_email and any(
            role["name"] in MANAGER_ROLES for role in member["roles"]
        ):
            return True
    return False


def add_user_to_group(user_email, group_email):
    parent = get_group_parent(group_email)
    new_member = {
        "preferredMemberKey": {"id": user_email},
        "roles": [{"name": "MEMBER"}],
    }
    request = (
        service.groups()
        .memberships()
        .create(parent=parent, body=new_member)
    )
    return request.execute()
