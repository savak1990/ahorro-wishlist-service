package utils

import (
	"encoding/json"
	"net/http"
)

func WriteJSONError(w http.ResponseWriter, status int, code string, errMsg string) {

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	response := map[string]string{"code": code, "error": errMsg}
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode error response", http.StatusInternalServerError)
		w.Write([]byte(`{"code":"InternalServerError","error":"Failed to encode error response"}`))
	}
}
