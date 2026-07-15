from fastapi import HTTPException, status

credentials_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="invalid or expired credentials",
    headers={"WWW-Authenticate": "Bearer"},
)

not_found_exception = HTTPException(
    status_code=status.HTTP_404_NOT_FOUND,
    detail="resource not found",
)

forbidden_exception = HTTPException(
    status_code=status.HTTP_403_FORBIDDEN,
    detail="access denied",
)

conflict_exception = HTTPException(
    status_code=status.HTTP_409_CONFLICT,
    detail="resource already exists",
)
