package main

import (
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"time"
)

func main() {
	target := "http://172.17.0.1:1234" // Dirección del servidor Ollama en el host EC2
	log.Printf("🌐 Intentando conectar a: %s", target)

	remote, err := url.Parse(target)
	if err != nil {
		log.Fatalf("Error al parsear la URL de destino: %v", err)
	}

	proxy := httputil.NewSingleHostReverseProxy(remote)

	// Cambia el director de transporte para mostrar errores de conexión
	proxy.Transport = &http.Transport{
		Proxy: http.ProxyFromEnvironment,
	}

	// Log de cada respuesta del backend
	proxy.ModifyResponse = func(resp *http.Response) error {
		log.Printf("RESPUESTA %s %s → %d", resp.Request.Method, resp.Request.URL.Path, resp.StatusCode)
		return nil
	}

	// Log de errores del proxy
	proxy.ErrorHandler = func(w http.ResponseWriter, r *http.Request, err error) {
		log.Printf("ERROR PROXY: %s %s → %v", r.Method, r.URL.Path, err)
		w.WriteHeader(http.StatusBadGateway)
		_, _ = io.WriteString(w, "Proxy Error: "+err.Error())
	}

	// Maneja todas las rutas
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.Printf("PETICIÓN %s %s desde %s", r.Method, r.URL.Path, r.RemoteAddr)
		proxy.ServeHTTP(w, r)
		log.Printf("Tiempo de respuesta: %s", time.Since(start))
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Proxy Gateway escuchando en :%s → %s", port, target)
	err = http.ListenAndServe(":"+port, nil)
	if err != nil {
		log.Fatalf("Falló el servidor: %v", err)
	}
}
