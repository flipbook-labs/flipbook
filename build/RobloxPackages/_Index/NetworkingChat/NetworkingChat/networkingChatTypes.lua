--!strict
export type Config = {
	roduxNetworking: any,
}

export type MessageId = string | number
export type ConversationId = string | number
export type UserId = string | number

export type UserIds = { UserId }
export type ConversationIds = { ConversationId }

export type AddToConversationRequest = {
	API: (participantUserIds: UserIds, conversationId: ConversationId) -> any,
	[string]: any
}
export type GetChatSettingsRequest = {
	API: () -> any,
	[string]: any
}
export type GetConversationsRequest = {
	API: (conversationIds: ConversationIds) -> any,
	[string]: any
}
export type GetLatestMessagesRequest = {
	API: (conversationIds: ConversationIds, pageSize: number) -> any,
	[string]: any
}
export type GetMessagesRequest = {
	API: (conversationId: ConversationId, pageSize:  number, exclusiveStartMessageId: MessageId?) -> any,
	[string]: any
}
export type GetMetadataRequest = {
	API: () -> any,
	[string]: any
}
export type GetRolloutSettingsRequest = {
	API: (featureNames: { string }) -> any,
	[string]: any
}
export type GetUnreadConversationCountRequest = {
	API: () -> any,
	[string]: any
}
export type GetUnreadMessagesRequest = {
	API: (conversationIds: ConversationIds, pageSize: number) -> any,
	[string]: any
}
export type GetUserConversationsRequest = {
	API: (pageNumber: number, pageSize:  number) -> any,
	[string]: any
}
export type MarkAsReadRequest = {
	API: (conversationId: ConversationId, endMessageId: MessageId) -> any,
	[string]: any
}
export type MarkAsSeenRequest = {
	API: (conversationIds: ConversationIds) -> any,
	[string]: any
}
export type RemoveFromConversationRequest = {
	API: (participantUserId: UserId, conversationId: ConversationId) -> any,
	[string]: any
}
export type RenameGroupConversationRequest = {
	API: (conversationId: ConversationId, newTitle: string) -> any,
	[string]: any
}
export type ResetConversationUniverseRequest = {
	API: (conversationId: ConversationId) -> any,
	[string]: any
}
export type SendGameLinkMessageRequest = {
	API: (universeId:  string, conversationId: ConversationId, decorators: { string }?) -> any,
	[string]: any
}
export type SendMessageRequest = {
	API: (message: string, conversationId: ConversationId, decorators: { string }?) -> any,
	[string]: any
}
export type SetConversationUniverseRequest = {
	API: (conversationId: ConversationId, universeId: string) -> any,
	[string]: any
}
export type StartGroupConversationRequest = {
	API: (participantUserIds: UserIds, title: string?) -> any,
	[string]: any
}
export type StartOneToOneConversationRequest = {
	API: (participantUserId: UserId) -> any,
	[string]: any
}
export type UpdateUserTypingStatusRequest = {
	API: (conversationId: ConversationId, isTyping: boolean?) -> any,
	[string]: any
}

export type RequestThunks = {
	AddToConversation: AddToConversationRequest,
	RemoveFromConversation: RemoveFromConversationRequest,
	RenameGroupConversation: RenameGroupConversationRequest,
	StartGroupConversation: StartGroupConversationRequest,
	StartOneToOneConversation: StartOneToOneConversationRequest,
	SetConversationUniverse: SetConversationUniverseRequest,
	ResetConversationUniverse: ResetConversationUniverseRequest,
	SendMessage: SendMessageRequest,
	SendGameLinkMessage: SendGameLinkMessageRequest,
	UpdateUserTypingStatus: UpdateUserTypingStatusRequest,
	MarkAsRead: MarkAsReadRequest,
	MarkAsSeen: MarkAsSeenRequest,
	GetMessages: GetMessagesRequest,
	GetUserConversations: GetUserConversationsRequest,
	GetConversations: GetConversationsRequest,
	GetLatestMessages: GetLatestMessagesRequest,
	GetUnreadConversationCount: GetUnreadConversationCountRequest,
	GetUnreadMessages: GetUnreadMessagesRequest,
	GetChatSettings: GetChatSettingsRequest,
	GetRolloutSettings: GetRolloutSettingsRequest,
	GetMetadata: GetMetadataRequest,
}

return {}
