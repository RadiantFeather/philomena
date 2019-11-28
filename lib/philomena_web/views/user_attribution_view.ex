defmodule PhilomenaWeb.UserAttributionView do
  alias Philomena.Attribution
  use Bitwise
  use PhilomenaWeb, :view

  def anonymous?(object) do
    Attribution.anonymous?(object)
  end

  def anonymous_name(object) do
    salt = anonymous_name_salt()
    id = Attribution.object_identifier(object)
    user_id = Attribution.best_user_identifier(object)

    hash =
      (:erlang.crc32(salt <> id <> user_id) &&& 0xffff)
      |> Integer.to_string(16)
      |> String.pad_leading(4, "0")

    "Background Pony ##{hash}"
  end

  def anonymous_avatar(_object, class \\ "avatar--100px") do
    img_tag(Routes.static_path(PhilomenaWeb.Endpoint, "/images/no_avatar.svg"), class: class)
  end

  def user_avatar(object, class \\ "avatar--100px")

  def user_avatar(%{user: nil} = object, class),
    do: anonymous_avatar(object, class)
  def user_avatar(%{user: %{avatar: nil}} = object, class),
    do: anonymous_avatar(object, class)
  def user_avatar(%{user: %{avatar: avatar}}, class),
    do: img_tag(avatar_url_root() <> "/" <> avatar, class: class)

  def user_labels(%{user: user}) do
    []
    |> personal_title(user)
    |> secondary_role(user)
    |> staff_role(user)
  end

  defp personal_title(labels, %{personal_title: t}) when t not in [nil, ""],
    do: [{"label--primary", t} | labels]
  defp personal_title(labels, _user),
    do: labels

  defp secondary_role(labels, %{secondary_role: t}) when t not in [nil, ""],
    do: [{"label--warning", t} | labels]
  defp secondary_role(labels, _user),
    do: labels

  defp staff_role(labels, %{hide_default_role: false, role: "admin"}),
    do: [{"label--danger", "Site Administrator"} | labels]
  defp staff_role(labels, %{hide_default_role: false, role: "moderator"}),
    do: [{"label--success", "Site Moderator"} | labels]
  defp staff_role(labels, %{hide_default_role: false, role: "assisant"}),
    do: [{"label--purple", "Site Assistant"} | labels]
  defp staff_role(labels, _user),
    do: labels

  defp avatar_url_root do
    Application.get_env(:philomena, :avatar_url_root)
  end

  defp anonymous_name_salt do
    Application.get_env(:philomena, :anonymous_name_salt)
    |> to_string()
  end
end
