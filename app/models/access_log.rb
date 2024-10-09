class AccessLog < ApplicationRecord
  validates :verb, presence: true

  VERBS = [
    HTTP_GET = 'GET'.freeze,
    HTTP_PUT = 'PUT'.freeze,
    HTTP_POST = 'POST'.freeze,
    HTTP_PATCH = 'PATCH'.freeze,
    HTTP_DELETE = 'DELETE'.freeze,
    HTTP_HEAD = 'HEAD'.freeze,
    HTTP_CONNECT = 'CONNECT'.freeze,
    HTTP_OPTIONS = 'OPTIONS'.freeze,
    HTTP_TRACE = 'TRACE'.freeze,
  ].freeze

  enum :verb, {
    GET: HTTP_GET,
    PUT: HTTP_PUT,
    POST: HTTP_POST,
    PATCH: HTTP_PATCH,
    DELETE: HTTP_DELETE,
    HEAD: HTTP_HEAD,
    CONNECT: HTTP_CONNECT,
    OPTIONS: HTTP_OPTIONS,
    TRACE: HTTP_TRACE,
  }
end
